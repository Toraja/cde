#!/bin/bash
set -eo pipefail

sudo apt-get update
sudo apt-get upgrade --no-install-recommends --yes
sudo apt-get install --no-install-recommends --yes \
    build-essential \
    gdb

source ${HOME}/.asdf/asdf.sh
# protoc is required by rust-analyzer
asdf-global-installer.sh rust rust-analyzer protoc
rustup completions fish > ~/.config/fish/completions/rustup.fish
rustup component add rust-src rust-analysis rustfmt clippy
curl -LsSf https://get.nexte.st/latest/linux | tar zxf - -C $(dirname $(asdf which cargo))
