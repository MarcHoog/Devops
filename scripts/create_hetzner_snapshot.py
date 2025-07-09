#!/usr/bin/env python3
import os, json, subprocess, argparse
from typing import Dict

def lookup_snapshots() -> Dict:
    out = subprocess.check_output([
        "hcloud", "image", "list", "-t", "snapshot", "--output", "json"
    ])
    images = json.loads(out)
    return images

def delete_snapshot(snapshot_id) -> bool:
    try:
        subprocess.check_output([
            "hcloud", "image", "delete", f"{snapshot_id}"
        ]
    )
        return True
    except subprocess.CalledProcessError as e:
        print("Exit code:", e.returncode)
        return False

def create_snapshot(machine: Dict) -> bool:
    try:
        subprocess.check_output([
            "hcloud", 
            "server", 
            "create-image",
            "--type",
            "snapshot", 
            "--description",
            f"vm-snapshot-{machine['name']}",
            str(machine["id"])
        ])
    except subprocess.CalledProcessError as e:
        print("Exit code:", e.returncode)
        return False

    return True


def lookup_machines() -> Dict:
    out = subprocess.check_output([
        "hcloud", "server", "list", "--output", "json" 
    ])
    machines = json.loads(out)
    return machines



def main():
    snapshots = lookup_snapshots()
    snapshot_descriptions = {x.get('description', "").removeprefix("vm-snapshot-"): x['id'] for x in snapshots}
    machines = lookup_machines()

    for m in machines:
        name = m["name"]
        print(f"machine {name}")
        if name in snapshot_descriptions:
            print("Deleting existing Snapshot of Machine ")
            deleted = delete_snapshot(snapshot_descriptions[name])
            if not deleted:
                print("Couldn't delete snapshot so skipping creating a new one")
                continue

        print("attempting to create snapshots")
        created = create_snapshot(m)
        if not created:
            print("Something went wrong creating a new Image")

        




if __name__ == "__main__":
    main()