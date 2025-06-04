#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
cp -- $script_dir/yaml.toml ~/.config/mise/conf.d/
mise install

mise exec fzf --command "npm install --global vscode-langservers-extracted yaml-language-server"
