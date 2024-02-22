#!/bin/bash
set -eo pipefail

sudo apt-get update
sudo apt-get upgrade --no-install-recommends --yes
sudo apt-get install --no-install-recommends --yes \
    libedit-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    libbz2-dev \
    libsqlite3-dev

source ${HOME}/.asdf/asdf.sh
asdf-global-installer.sh python

for package in pyright pipenv poetry; do pipx install $package; done
