#!/bin/bash
set -eo pipefail

sudo apt-get update
# See https://github.com/mise-plugins/mise-lua for the required dependencies.
# It should work without `linux-headers-$(uname -r)` package.
# `libreadline-dev` is required to enable readline for lua 5.4 and above, when it is compiled with readline enabled.
# Setting ASDF_LUA_LINUX_READLINE=1 will enable readline when installing via asdf (a backend mise uses).
sudo apt-get install --no-install-recommends --yes \
  build-essential libreadline-dev

script_dir=$(dirname "$0")
catalog_name=$(basename "$script_dir")

if [ -f "$script_dir/${catalog_name}.toml" ]; then
  cp -- "$script_dir/${catalog_name}.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/${catalog_name}/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/${catalog_name}/postinstall/"* ~/.config/mise/tasks/postinstall/
fi
# Specify luarock version as 3.13.0 is broken: https://github.com/luarocks/luarocks/issues/1851
ASDF_LUA_LINUX_READLINE=1 ASDF_LUA_LUAROCKS_VERSION=3.12.2 mise install
