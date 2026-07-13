import json
import argparse
import sys
from pathlib import Path

def is_subset(sub: dict, super: dict):
    return all(k in super and super[k] == v for k, v in sub.items())

parser = argparse.ArgumentParser()
parser.add_argument("json_base")
parser.add_argument("json_override")
args = parser.parse_args()

base_json_file = Path(args.json_base)
override_json_file = Path(args.json_override)

base_json = {}
if base_json_file.exists():
    with base_json_file.open() as base:
        base_json = json.load(base)

with override_json_file.open() as override:
    override_json = json.load(override)

if is_subset(override_json, base_json):
    # Everything is contained already
    sys.exit(1)

merged_json = {**base_json, **override_json}

with open(base_json_file, "w") as out:
    json.dump(merged_json, out, indent=2)

sys.exit(0)
