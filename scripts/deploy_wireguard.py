#!/usr/bin/env python3
"""Deploy and manage a simple WireGuard VPN.

Example usage:
    sudo python3 scripts/deploy_wireguard.py deploy --endpoint 1.2.3.4
    sudo python3 scripts/deploy_wireguard.py add-client --name alice --endpoint 1.2.3.4
    sudo python3 scripts/deploy_wireguard.py remove-client --name alice
"""

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import List, Optional

from jinja2 import Template

WG_DIR = Path("/etc/wireguard")
SERVER_PRIV = WG_DIR / "server_private.key"
SERVER_PUB = WG_DIR / "server_public.key"
SERVER_CONF = WG_DIR / "wg0.conf"
CLIENT_DIR = WG_DIR / "clients"
DEFAULT_NET = "10.8.0.0/24"
DEFAULT_PORT = 51820


def run(cmd: List[str]) -> None:
    subprocess.run(cmd, check=True)


def ensure_root() -> None:
    if os.geteuid() != 0:
        sys.exit("This script must be run as root.")


def install_wireguard() -> None:
    run(["apt-get", "update"])
    run(["apt-get", "install", "-y", "wireguard", "iptables"])


def generate_keypair(private_path: Path, public_path: Path) -> None:
    private = subprocess.check_output(["wg", "genkey"]).strip()
    public = subprocess.check_output(["wg", "pubkey"], input=private).strip()
    private_path.write_bytes(private + b"\n")
    public_path.write_bytes(public + b"\n")
    private_path.chmod(0o600)
    public_path.chmod(0o600)


def get_default_iface() -> str:
    out = subprocess.check_output(["bash", "-c", "ip route | awk '/default/ {print $5; exit}'"])
    return out.decode().strip()


def render_server_conf(private_key: str, address: str, listen_port: int, iface: str) -> str:
    tmpl = Template(
        """[Interface]\nAddress = {{ address }}\nListenPort = {{ port }}\nPrivateKey = {{ private }}\nPostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o {{ iface }} -j MASQUERADE\nPostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o {{ iface }} -j MASQUERADE\n"""
    )
    return tmpl.render(address=address, port=listen_port, private=private_key, iface=iface)


def render_client_conf(private_key: str, address: str, server_pub: str, endpoint: str, listen_port: int) -> str:
    tmpl = Template(
        """[Interface]\nPrivateKey = {{ private }}\nAddress = {{ address }}\n\n[Peer]\nPublicKey = {{ server_pub }}\nEndpoint = {{ endpoint }}:{{ port }}\nAllowedIPs = 0.0.0.0/0\nPersistentKeepalive = 25\n"""
    )
    return tmpl.render(private=private_key, address=address, server_pub=server_pub, endpoint=endpoint, port=listen_port)


def enable_ip_forwarding() -> None:
    path = Path("/etc/sysctl.d/99-wireguard-forwarding.conf")
    path.write_text("net.ipv4.ip_forward=1\n")
    run(["sysctl", "-p", str(path)])


def restart_service(interface: str) -> None:
    run(["systemctl", "restart", f"wg-quick@{interface}"])


def parse_used_ips() -> List[str]:
    if not SERVER_CONF.exists():
        return []
    ips = []
    for line in SERVER_CONF.read_text().splitlines():
        if line.strip().startswith("AllowedIPs"):
            ip = line.split("=")[1].strip().split(",")[0].strip()
            ips.append(ip)
    return ips


def next_available_ip() -> str:
    used = parse_used_ips()
    for i in range(2, 255):
        candidate = f"10.8.0.{i}/32"
        if candidate not in used:
            return candidate
    raise RuntimeError("No free IP addresses")


def add_client(name: str, endpoint: str, address: Optional[str], listen_port: int) -> None:
    CLIENT_DIR.mkdir(exist_ok=True)
    priv = CLIENT_DIR / f"{name}_private.key"
    pub = CLIENT_DIR / f"{name}_public.key"
    generate_keypair(priv, pub)

    if not SERVER_PUB.exists():
        raise RuntimeError("Server keys not found. Deploy server first.")

    if not address:
        address = next_available_ip()

    server_pub = SERVER_PUB.read_text().strip()
    client_priv = priv.read_text().strip()
    client_conf = render_client_conf(client_priv, address, server_pub, endpoint, listen_port)
    conf_path = CLIENT_DIR / f"{name}.conf"
    conf_path.write_text(client_conf)

    peer_block = f"\n# {name}\n[Peer]\nPublicKey = {pub.read_text().strip()}\nAllowedIPs = {address}\n"
    with open(SERVER_CONF, "a") as f:
        f.write(peer_block)

    restart_service("wg0")
    print(f"Created client config {conf_path}")


def remove_client(name: str) -> None:
    if not SERVER_CONF.exists():
        raise RuntimeError("Server config missing")
    lines = SERVER_CONF.read_text().splitlines()
    new_lines = []
    skip = False
    for line in lines:
        if line.strip() == f"# {name}":
            skip = True
            continue
        if skip and line.startswith("[Peer]"):
            continue
        if skip and line.strip().startswith("AllowedIPs"):
            skip = False
            continue
        if not skip:
            new_lines.append(line)
    SERVER_CONF.write_text("\n".join(new_lines) + "\n")
    priv = CLIENT_DIR / f"{name}_private.key"
    pub = CLIENT_DIR / f"{name}_public.key"
    conf = CLIENT_DIR / f"{name}.conf"
    for path in [priv, pub, conf]:
        if path.exists():
            path.unlink()
    restart_service("wg0")
    print(f"Removed client {name}")


def deploy_server(address: str, listen_port: int) -> None:
    install_wireguard()
    WG_DIR.mkdir(exist_ok=True)
    if not SERVER_PRIV.exists():
        generate_keypair(SERVER_PRIV, SERVER_PUB)
    private_key = SERVER_PRIV.read_text().strip()
    iface = get_default_iface()
    conf = render_server_conf(private_key, address, listen_port, iface)
    SERVER_CONF.write_text(conf)
    enable_ip_forwarding()
    run(["systemctl", "enable", f"wg-quick@wg0"])
    restart_service("wg0")
    print("WireGuard server deployed.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Deploy and manage WireGuard VPN")
    sub = parser.add_subparsers(dest="command", required=True)

    d = sub.add_parser("deploy", help="Deploy server")
    d.add_argument("--address", default=DEFAULT_NET)
    d.add_argument("--listen-port", type=int, default=DEFAULT_PORT)

    add = sub.add_parser("add-client", help="Create a client configuration")
    add.add_argument("--name", required=True)
    add.add_argument("--endpoint", required=True)
    add.add_argument("--address")
    add.add_argument("--listen-port", type=int, default=DEFAULT_PORT)

    rm = sub.add_parser("remove-client", help="Remove a client")
    rm.add_argument("--name", required=True)

    args = parser.parse_args()
    ensure_root()

    if args.command == "deploy":
        deploy_server(args.address, args.listen_port)
    elif args.command == "add-client":
        add_client(args.name, args.endpoint, args.address, args.listen_port)
    elif args.command == "remove-client":
        remove_client(args.name)


if __name__ == "__main__":
    main()
