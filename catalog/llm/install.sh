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

mkdir --parents ~/.config/opencode/ ~/.local/share/opencode ~/.cde/mnt/shared/.local/share/opencode
# opencode config might need to be localised (custom providers) while tui config does not
cp --force ~/toybox/opencode/opencode.jsonc ~/.config/opencode/
ln --symbolic ~/toybox/opencode/tui.jsonc ~/.config/opencode/
ln --symbolic ~/.cde/mnt/shared/.local/share/opencode/account.json ~/.local/share/opencode/
ln --symbolic ~/.cde/mnt/shared/.local/share/opencode/auth.json ~/.local/share/opencode/

mise exec node --command "npm install --global @fission-ai/openspec@latest"
mise run postinstall:openspec
