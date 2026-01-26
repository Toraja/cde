#!/bin/bash
set -eo pipefail

# TODO: is it possible to override rust version in mise.toml?
# rust_version=${1:-latest}

sudo apt-get update
# pkg-config: required by rust-openssl crate which reqwest crate depends on
sudo apt-get install --no-install-recommends --yes \
  build-essential \
  pkg-config

script_dir=$(dirname "$0")
catalog_name=$(basename "$script_dir")

if [ -f "$script_dir/${catalog_name}.toml" ]; then
  cp -- "$script_dir/${catalog_name}.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/${catalog_name}/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/${catalog_name}/postinstall/"* ~/.config/mise/tasks/postinstall/
fi
mise install

# required by nvim-neotest
# curl --location --silent --show-error --fail https://get.nexte.st/latest/linux | tar -zxf - --directory $(dirname $(asdf which cargo))
mise exec rust cargo-binstall --command 'cargo binstall cargo-nextest --secure'
