#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
go_version=${1:-latest}

setup_hook() {
    echo 'post_asdf_install_golang = install-golang-toolchains $@' >> ~/.asdfrc
    cp $script_dir/install-golang-toolchains ~/.local/bin/
}

mkdir -p ${HOME}/go
source ${HOME}/.asdf/asdf.sh
setup_hook
asdf-global-installer.sh golang:${go_version} richgo
