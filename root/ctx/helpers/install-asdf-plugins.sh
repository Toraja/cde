#!/bin/bash

set -e

source ~/.asdf/asdf.sh

# tmux is installed via apt because it requireds build dependencies and asdf does not resolve the dependency.
# For the record, those dependencies are zip, unzip, automake as well as packages written on
# https://github.com/tmux/tmux/wiki/Installing#from-source-tarball .
asdf-global-installer.sh \
    direnv \
    neovim \
    nodejs \
    grpcurl \
    ghq \
    lazygit \
    github-cli \
    fd \
    bat \
    fzf \
    cheat \
    fx \
    yq \
    just \
    glow

asdf direnv setup --shell fish --version latest
just --completions fish > ~/.config/fish/completions/just.fish
npm install --global yaml-language-server
eval $(asdf where fzf)/install --all
# NOTE: remove fish_user_key_bindings.fish created by fzf installer.
# It is loaded when (and somehow only when) script with fish shebang is executed.
# Since fzf_key_bindings is only loaded in interactive mode, fish complains that
# fzf_key_bindings function is not found.
# With installer's --no-key-bindings option, fzf_key_bindings function will not be defind
# and fzf widget will be unavaliable entirely.
rm -f ~/.config/fish/functions/fish_user_key_bindings.fish

git clone --depth 1 https://github.com/cheat/cheatsheets.git ~/.config/cheat/cheatsheets/community
ln -s ~/toybox/cheat/conf.yml ~/.config/cheat/conf.yml
ln -s ~/toybox/cheat/cheatsheets ~/.config/cheat/cheatsheets/personal
curl -fsSL -o ~/.config/fish/completions/cheat.fish https://raw.githubusercontent.com/cheat/cheat/master/scripts/cheat.fish
