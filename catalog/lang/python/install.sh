#!/bin/bash
set -eo pipefail

sudo apt-get update
# liblzma-dev is required by cohere package
sudo apt-get install --no-install-recommends --yes \
    libedit-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    libbz2-dev \
    libsqlite3-dev \
    liblzma-dev

export PATH="$HOME/.asdf/shims:$PATH"
asdf-global-installer.sh python

for package in pyright pipenv poetry ruff; do pipx install $package; done

poetry completions fish > ~/.config/fish/completions/poetry.fish
