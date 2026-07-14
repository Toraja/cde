import json
import argparse
import sys
import os
from pathlib import Path


def load_json_or_empty_dict(path: str) -> dict:
    json_file = Path(path)

    if not json_file.exists():
        return {}

    with json_file.open() as base:
        return json.load(base)


def is_subset(sub: dict, super: dict) -> bool:
    for sub_key, sub_value in sub.items():
        if sub_key not in super:
            return False
        if isinstance(sub_value, dict):
            if not isinstance(super[sub_key], dict):
                return False
            if not is_subset(sub_value, super[sub_key]):
                return False
        else:
            if super[sub_key] != sub_value:
                return False
    return True


def make_proxy_config() -> dict:
    def get_proxy(name: str):
        return os.getenv(name.lower()) or os.getenv(name.upper())

    names = ("http_proxy", "https_proxy", "no_proxy")
    proxies = {name: value for name in names if (value := get_proxy(name)) is not None}
    return {
        "proxies": {
            "default": proxies,
        }
    }


def main() -> int:
    """
    Returns 0 if config is updated, 1 if not.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("base_config_path")
    parser.add_argument("override_config_path")
    args = parser.parse_args()

    base_config = load_json_or_empty_dict(args.base_config_path)
    override_config = load_json_or_empty_dict(args.override_config_path)
    override_config.update(make_proxy_config())

    if is_subset(override_config, base_config):
        return 1

    base_config.update(override_config)
    with open(args.base_config_path, "w") as out:
        json.dump(base_config, out, indent=2)

    return 0


if __name__ == "__main__":
    sys.exit(main())
