#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
# TODO: is it possible to override golang version in mise.toml?
# go_version=${1:-latest}

mkdir --parents ${HOME}/go
cp -- $script_dir/go.toml ~/.config/mise/conf.d/
cp -- $script_dir/go ~/.config/mise/tasks/postinstall/
mise install
