#!/bin/bash
set -eo pipefail

sudo apt-get update
# lsof is required by opencode.nvim
sudo apt-get install --no-install-recommends --yes \
  lsof

script_dir=$(dirname "$0")
catalog_name=$(basename "$script_dir")
mise_install=false

if [ -f "$script_dir/${catalog_name}.toml" ]; then
  cp -- "$script_dir/${catalog_name}.toml" ~/.config/mise/conf.d/
  mise_install=true
fi
if ls "$script_dir/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/postinstall/"* ~/.config/mise/tasks/postinstall/
fi
if $mise_install; then
  mise install
fi

mise exec uv --command "uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"

mise exec node --command "npm install --global @fission-ai/openspec@latest"
# During installation, mise has not been activated so openspec is not in PATH.
# Use postinstall script so that the script is run in mise-activated sesson.
mise run postinstall:openspec
