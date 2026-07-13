#!/bin/bash
set -eo pipefail

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

# --- Add other commands ---
sudo apt-get update
# xz-utils is required to extract the adrs installer
sudo apt-get install --no-install-recommends --yes \
  xz-utils

curl --proto '=https' --tlsv1.2 -LsSf https://github.com/joshrotenberg/adrs/releases/latest/download/adrs-installer.sh | sh
$HOME/.cargo/bin/adrs completions fish > ~/.config/fish/completions/adrs.fish
