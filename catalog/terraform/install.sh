#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
catalog_name=$(basename "$script_dir")

if [ -f "$script_dir/${catalog_name}.toml" ]; then
  cp -- "$script_dir/${catalog_name}.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/${catalog_name}/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/${catalog_name}/postinstall/"* ~/.config/mise/tasks/postinstall/
fi
mise install
