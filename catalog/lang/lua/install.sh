#!/bin/bash
set -eo pipefail

sudo apt-get update
# unzip is required by mise install lua
sudo apt-get install --no-install-recommends --yes \
    build-essential libreadline-dev unzip

script_dir=$(dirname "$0")
cp -- $script_dir/lua.toml ~/.config/mise/conf.d/
cp -- $script_dir/lua ~/.config/mise/tasks/postinstall/

# luajit is avaialbe as mise tool but it fails to install, so build manually instead
tmpdir=$(mktemp --directory)
git clone --depth 1 https://github.com/LuaJIT/LuaJIT.git $tmpdir
cd $tmpdir
make && sudo make install
rm -rf $tmpdir
