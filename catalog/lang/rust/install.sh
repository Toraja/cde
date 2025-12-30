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

cp -- $script_dir/rust.toml ~/.config/mise/conf.d/
cp -- $script_dir/rust ~/.config/mise/tasks/postinstall/
mise install

# required by nvim-neotest
# curl --location --silent --show-error --fail https://get.nexte.st/latest/linux | tar -zxf - --directory $(dirname $(asdf which cargo))
mise exec rust cargo-binstall --command 'cargo binstall cargo-nextest --secure'
