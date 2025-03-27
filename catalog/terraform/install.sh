#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
cp -- $script_dir/terraform.toml ~/.config/mise/conf.d/
