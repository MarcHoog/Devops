#!/usr/bin/env python3
"""
Bootstrap a single-node K3s cluster with FluxCD using a personal GitHub repo.

This script ensures idempotency: safe to run multiple times.
It installs K3s and Flux only if missing, and bootstraps Flux
only if it’s not already configured in the cluster.
"""

import os
import sys
import shutil
import subprocess
from pathlib import Path
from getpass import getpass


def print_info(msg):
    """Print an info message in blue."""
    print(f"\033[94mℹ️  {msg}\033[0m")


def print_success(msg):
    """Print a success message in green."""
    print(f"\033[92m✅ {msg}\033[0m")


def print_warn(msg):
    """Print a warning message in yellow."""
    print(f"\033[93m⚠️  {msg}\033[0m")


def print_error(msg):
    """Print an error message in red."""
    print(f"\033[91m❌ {msg}\033[0m")


def run_command(cmd, check=True, capture_output=False, **kwargs):
    """
    Run a system command and handle errors.

    Args:
        cmd (list): Command and arguments as a list.
        check (bool): Raise error if command fails.
        capture_output (bool): Capture stdout/stderr.

    Returns:
        subprocess.CompletedProcess
    """
    try:
        return subprocess.run(
            cmd,
            check=check,
            capture_output=capture_output,
            text=True,
            **kwargs
        )
    except subprocess.CalledProcessError as e:
        print_error(f"Command failed: {' '.join(cmd)}")
        if e.stderr:
            print_error(e.stderr.strip())
        sys.exit(1)


def is_installed(command):
    """
    Check if a command is available in PATH.

    Args:
        command (str): The command to check.

    Returns:
        bool: True if installed.
    """
    return shutil.which(command) is not None


def install_flux():
    """
    Install the Flux CLI if not already installed.
    """
    if is_installed("flux"):
        print_success("Flux is already installed.")
        return

    print_info("Installing Flux CLI...")
    run_command([
        "bash", "-c",
        "curl -s https://fluxcd.io/install.sh | sudo bash"
    ])


def install_k3s():
    """
    Install K3s if it is not already installed.
    """
    if Path("/etc/rancher/k3s").exists():
        print_success("K3s is already installed.")
        return

    print_info("Installing K3s...")
    run_command([
        "bash", "-c",
        "curl -sfL https://get.k3s.io | sh -"
    ])


def validate_env_var(name, prompt=None, secret=False):
    """
    Ensure an environment variable is set or ask user.

    Args:
        name (str): The env variable name.
        prompt (str): Optional custom prompt.
        secret (bool): Use getpass if True.

    Returns:
        str: The value provided.
    """
    val = os.getenv(name)
    if not val:
        if prompt is None:
            prompt = f"Enter {name.replace('_', ' ').title()}"
        val = getpass(prompt + ": ") if secret else input(prompt + ": ")
        if not val:
            print_error(f"{name} is required.")
            sys.exit(1)

    os.environ[name] = val

    return val


def is_flux_bootstrapped():
    """
    Check if Flux is already bootstrapped in the cluster.

    Returns:
        bool: True if bootstrapped.
    """
    try:
        result = run_command(["flux", "check"], capture_output=True)
        return "install success" in result.stdout.lower()
    except Exception:
        return False


def bootstrap_flux(github_owner, github_repo, github_branch, github_path):
    """
    Bootstrap Flux into the Kubernetes cluster.

    Args:
        github_owner (str): GitHub username or org.
        github_repo (str): Repository name.
        github_branch (str): Git branch name.
        github_path (str): Path in repo to use for sync.
    """
    if is_flux_bootstrapped():
        print_success("Flux is already bootstrapped.")
        return

    print_info("Bootstrapping Flux from GitHub...")
    run_command([
        "flux", "bootstrap", "github",
        "--token-auth",
        "--personal"
    ])

    print_success(
        f"Flux bootstrapped from '{github_owner}/{github_repo}' "
        f"(branch: {github_branch}, path: {github_path})"
    )


def main():
    """Main entrypoint: install dependencies and bootstrap Flux."""
    print_info("🚀 Starting idempotent K3s + Flux bootstrap...")

    for tool in ["curl", "bash", "sudo"]:
        if not is_installed(tool):
            print_error(f"{tool} is not installed or not in PATH.")
            sys.exit(1)

    github_owner = validate_env_var(
        "GH_USERNAME", "GitHub Username"
    )
    github_repo = validate_env_var(
        "GH_REPOSITORY", "GitHub Repository"
    )
    github_branch = validate_env_var(
        "GH_BRANCH", "GitHub Branch [default: main]"
    ) or "main"
    github_path = validate_env_var(
        "GH_PATH", "Flux path in repository [e.g. clusters/dev]"
    )

    kubeconfig = validate_env_var(
        "KUBECONFIG", "Kubeconfig path [e.g. /etc/rancher/k3s/k3s.yaml]"
    )


    install_flux()
    install_k3s()
    bootstrap_flux(github_owner, github_repo, github_branch, github_path)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print_error("Aborted by user.")
