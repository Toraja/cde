#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
catalog_name=$(basename "$script_dir")

if [ -f "$script_dir/${catalog_name}.toml" ]; then
  cp -- "$script_dir/${catalog_name}.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/postinstall/"* ~/.config/mise/tasks/postinstall/
fi

# Install specify-cli with `mise exec` since `uv` is supposed to be installed in python catalog
mise exec uv --command "uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
