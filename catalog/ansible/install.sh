#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")

if [ -f "$script_dir/<catalog>.toml" ]; then
  cp -- "$script_dir/<catalog>.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/<catalog>/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/<catalog>/postinstall/"* ~/.config/mise/tasks/postinstall/
fi

pipx install --include-deps ansible
pipx inject --include-apps ansible ansible-lint
