#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
cp -- $script_dir/glab.toml ~/.config/mise/conf.d/
cp -- $script_dir/glab ~/.config/mise/tasks/postinstall/

cat << EOF > ~/.config/fish/conf.d/my-glab.fish
# glab CLI (as of v1.80.4) cannot handle multi-words value
set --export GLAB_EDITOR nvim
EOF
