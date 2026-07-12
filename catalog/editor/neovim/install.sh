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

mkdir --parents ~/.local/{share,state}/nvim/ ~/.cde/mnt/single/.local/state/nvim/shada/ ~/.cde/mnt/shared/.local/{share,state}/nvim/lazy/
ln --symbolic --force ~/.cde/mnt/single/.local/state/nvim/{shada,trust} ~/.local/state/nvim/
ln --symbolic --force ~/.cde/mnt/shared/.local/share/nvim/lazy ~/.local/share/nvim/
ln --symbolic --force ~/.cde/mnt/shared/.local/state/nvim/lazy ~/.local/state/nvim/
