#!/bin/bash

set -e

source ~/.asdf/asdf.sh

# tmux is installed via apt because it requireds C compiler and asdf does not resolve the dependency
asdf-global-installer.sh \
    direnv \
    neovim \
    lua \
    grpcurl \
    ghq \
    fd \
    bat \
    fzf \
    cheat \
    kubectl \
    kind \
    k9s \
    helm \
    helmfile

asdf direnv setup --shell fish --version latest
helm plugin install https://github.com/databus23/helm-diff
luarocks completion fish > ~/.config/fish/completions/luarocks.fish
kubectl completion fish > ~/.config/fish/completions/kubectl.fish
kind completion fish > ~/.config/fish/completions/kind.fish
k9s completion fish > ~/.config/fish/completions/k9s.fish
helm completion fish > ~/.config/fish/completions/helm.fish
eval $(asdf where fzf)/install --all

git clone --depth 1 https://github.com/cheat/cheatsheets.git ~/.config/cheat/cheatsheets/community
ln -s ~/toybox/cheat/conf.yml ~/.config/cheat/conf.yml
ln -s ~/toybox/cheat/cheatsheets ~/.config/cheat/cheatsheets/personal
curl -fsSL -o ~/.config/fish/completions/cheat.fish https://raw.githubusercontent.com/cheat/cheat/master/scripts/cheat.fish

krew-installer.sh
kubectl krew install tree tail ns
