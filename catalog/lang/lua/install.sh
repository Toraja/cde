#!/bin/bash
set -eo pipefail

sudo apt-get update
sudo apt-get install --no-install-recommends --yes \
    build-essential libreadline-dev

export PATH="$HOME/.asdf/shims:$PATH"
# neorg (luarocks.nvim) requires lua version to be 5.1
# If somehow luarocks.nvim supports lua 5.4, add ASDF_LUA_LINUX_READLINE=1
# See https://github.com/Stratus3D/asdf-lua?tab=readme-ov-file#linux-readline for more detail
asdf-global-installer.sh lua:5.1.5 stylua lua-language-server
# luajit is avaialbe as asdf plugin but it now fails to install, so build manually instead
tmp_luajit=/tmp/LuaJIT
git clone https://github.com/LuaJIT/LuaJIT.git $tmp_luajit
cd $tmp_luajit
make && sudo make install
rm -rdf $tmp_luajit

luarocks completion fish > ~/.config/fish/completions/luarocks.fish
luarocks install busted
