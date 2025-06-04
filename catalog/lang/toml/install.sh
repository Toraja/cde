#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
cp -- $script_dir/toml.toml ~/.config/mise/conf.d/
mise install
