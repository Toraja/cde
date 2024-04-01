#!/bin/bash
set -eo pipefail

sudo apt-get update
sudo apt-get upgrade --no-install-recommends --yes
sudo apt-get install --no-install-recommends --yes \
    build-essential libreadline-dev

source ${HOME}/.asdf/asdf.sh
# neorg (luarocks.nvim) requires lua version to be 5.1
# If somehow luarocks.nvim supports lua 5.4, add ASDF_LUA_LINUX_READLINE=1
# See https://github.com/Stratus3D/asdf-lua?tab=readme-ov-file#linux-readline for more detail
asdf-global-installer.sh lua:5.1.5 luajit stylua lua-language-server

luarocks completion fish > ~/.config/fish/completions/luarocks.fish
luarocks install busted
