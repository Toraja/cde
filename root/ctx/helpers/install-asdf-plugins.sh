#!/bin/bash

set -e

# tmux is installed via apt because it requireds build dependencies and asdf does not resolve the dependency.
# For the record, those dependencies are zip, unzip, automake as well as packages written on
# https://github.com/tmux/tmux/wiki/Installing#from-source-tarball .
asdf-global-installer.sh \
    neovim \
    nodejs \
    grpcurl \
    ghq \
    lazygit \
    github-cli \
    fd \
    ripgrep \
    bat \
    fzf \
    cheat \
    jq \
    fx \
    yq \
    just

export PATH="$HOME/.asdf/shims:$PATH"

mkdir --parents  ~/.local/{share,state}/nvim/ ~/.cde/mnt/single/.local/state/nvim/ ~/hosthome/.local/{share,state}/nvim/lazy/
ln -sf ~/.cde/mnt/single/.local/state/nvim/{shada,trust} ~/.local/state/nvim/
ln -s ~/hosthome/.local/share/nvim/lazy ~/.local/share/nvim/
ln -s ~/hosthome/.local/state/nvim/lazy ~/.local/state/nvim/

just --completions fish > ~/.config/fish/completions/just.fish

npm install --global vscode-langservers-extracted yaml-language-server json5

fzf --fish > ~/.config/fish/conf.d/fzf.fish

git clone --depth 1 https://github.com/cheat/cheatsheets.git ~/.config/cheat/cheatsheets/community
ln -s ~/toybox/cheat/conf.yml ~/.config/cheat/conf.yml
ln -s ~/toybox/cheat/cheatsheets ~/.config/cheat/cheatsheets/personal
curl -fsSL -o ~/.config/fish/completions/cheat.fish https://raw.githubusercontent.com/cheat/cheat/master/scripts/cheat.fish
