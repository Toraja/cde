#!/bin/bash
set -eo pipefail

rust_version=${1:-latest}

sudo apt-get update
sudo apt-get upgrade --no-install-recommends --yes
# pkg-config: required by rust-openssl crate which reqwest crate depends on
sudo apt-get install --no-install-recommends --yes \
    build-essential \
    gdb \
    pkg-config

source ${HOME}/.asdf/asdf.sh
# protoc is required by rust-analyzer
asdf-global-installer.sh rust:${rust_version} protoc sccache
rustup completions fish > ~/.config/fish/completions/rustup.fish
rustup component add rust-analyzer
# required by nvim-neotest
curl --location --silent --show-error --fail https://get.nexte.st/latest/linux | tar -zxf - --directory $(dirname $(asdf which cargo))
