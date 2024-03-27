#!/bin/bash
set -eo pipefail

sudo apt-get update
sudo apt-get upgrade --no-install-recommends --yes
sudo apt-get install --no-install-recommends --yes \
    build-essential

source ${HOME}/.asdf/asdf.sh
# neorg (luarocks.nvim) requires lua version to be 5.1
asdf-global-installer.sh lua:5.1.5 luajit stylua lua-language-server

luarocks completion fish > ~/.config/fish/completions/luarocks.fish
luarocks install busted
