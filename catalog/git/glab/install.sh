#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
cp -- $script_dir/glab.toml ~/.config/mise/conf.d/
cp -- $script_dir/glab ~/.config/mise/tasks/postinstall/
