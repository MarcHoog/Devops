#!/usr/bin/env python3
import os, json, subprocess, argparse

def lookup_snapshot(name):
    try:
        out = subprocess.check_output([
            "hcloud", "image", "list", "--selector", "type=snapshot", "--output", "json"
        ])
        images = json.loads(out)
        for img in images:
            if img.get("description") == f"vm-snapshot-{name}":
                return img["id"]
    except Exception:
        pass
    return ""  

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--name", required=True,
                   help="Space-separated list of node names")
    p.add_argument("--output", required=True,
                   help="Path to write JSON array")
    args = p.parse_args()

    with open(args.output, "w") as f:
        f.write(lookup_snapshot(args.name))

if __name__ == "__main__":
    main()
