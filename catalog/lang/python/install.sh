#!/bin/bash
set -eo pipefail

sudo apt-get update
# python3-venv is required by pipenv
sudo apt-get install --no-install-recommends --yes \
  python3-venv

script_dir=$(dirname "$0")
catalog_name=$(basename "$script_dir")

if [ -f "$script_dir/${catalog_name}.toml" ]; then
  cp -- "$script_dir/${catalog_name}.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/postinstall/"* ~/.config/mise/tasks/postinstall/
fi
mise install

packages=(
  pip
  pyright
)
for package in "${packages[@]}"; do
  mise exec uv --command "uv tool install $package"
done
