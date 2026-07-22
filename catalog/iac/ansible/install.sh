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

# Better to install them altogether to reduce duplicates
# https://docs.astral.sh/uv/concepts/tools/#installing-executables-from-additional-packages
mise exec uv --command "uv tool install --with-executables-from ansible-core,ansible-lint ansible"
