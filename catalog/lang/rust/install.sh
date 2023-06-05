#!/bin/bash
set -eo pipefail

sudo apt-get update
sudo apt-get upgrade --no-install-recommends --yes
sudo apt-get install --no-install-recommends --yes \
    build-essential \
    gdb

source ${HOME}/.asdf/asdf.sh
# protoc is required by rust-analyzer
asdf-global-installer.sh rust rust-analyzer protoc sccache
rustup completions fish > ~/.config/fish/completions/rustup.fish
rustup component add rust-src rust-analysis rustfmt clippy
# required by nvim-neotest
curl --location --silent --show-error --fail https://get.nexte.st/latest/linux | tar -zxf - --directory $(dirname $(asdf which cargo))