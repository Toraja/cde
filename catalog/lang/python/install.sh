#!/bin/bash
set -eo pipefail

sudo apt-get update
# liblzma-dev is required by cohere package
sudo apt-get install --no-install-recommends --yes \
  libedit-dev \
  zlib1g \
  zlib1g-dev \
  libssl-dev \
  libbz2-dev \
  libsqlite3-dev \
  liblzma-dev

script_dir=$(dirname "$0")

if [ -f "$script_dir/<catalog>.toml" ]; then
  cp -- "$script_dir/<catalog>.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/<catalog>/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/<catalog>/postinstall/"* ~/.config/mise/tasks/postinstall/
fi
mise install

packages=(
  pip
  pyright
)
for package in "${packages[@]}"; do
  pipx install $package
done
