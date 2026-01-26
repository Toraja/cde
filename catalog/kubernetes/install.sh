#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")

if [ -f "$script_dir/<catalog>.toml" ]; then
  cp -- "$script_dir/<catalog>.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/<catalog>/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/<catalog>/postinstall/"* ~/.config/mise/tasks/postinstall/
fi
mise install

github-latest-release-installer.sh -x mrjosh helm-ls helm_ls_linux_amd64 ~/.local/bin/helm_ls
