#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
cp -- $script_dir/kubernetes.toml ~/.config/mise/conf.d/

github-latest-release-installer.sh -x mrjosh helm-ls helm_ls_linux_amd64 ~/.local/bin/helm_ls
