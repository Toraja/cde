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
cp -- $script_dir/lua.toml ~/.config/mise/conf.d/
cp -- $script_dir/lua ~/.config/mise/tasks/postinstall/
ASDF_LUA_LINUX_READLINE=1 mise install
