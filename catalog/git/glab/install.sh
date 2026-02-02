#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
catalog_name=$(basename "$script_dir")

if [ -f "$script_dir/${catalog_name}.toml" ]; then
  cp -- "$script_dir/${catalog_name}.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/postinstall/"* ~/.config/mise/tasks/postinstall/
fi

cat << EOF > ~/.config/fish/conf.d/my-glab.fish
# glab CLI (as of v1.80.4) cannot handle multi-words value
set --export GLAB_EDITOR nvim
EOF
