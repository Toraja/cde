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
cp -- $script_dir/python.toml ~/.config/mise/conf.d/
# cp -- $script_dir/python ~/.config/mise/tasks/postinstall/
mise install

packages=(
  pip
  pyright
)
for package in "${packages[@]}"; do
  pipx install $package
done
