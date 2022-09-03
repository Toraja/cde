#!/bin/bash

set -e

source ~/.asdf/asdf.sh

# tmux is installed via apt because it requireds build dependencies and asdf does not resolve the dependency.
# For the record, those dependencies are zip, unzip, automake as well as packages written on
# https://github.com/tmux/tmux/wiki/Installing#from-source-tarball .
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
    fx \
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

luarocks install fennel
fnlfmt_version=0.2.3
curl -fsSL https://git.sr.ht/~technomancy/fnlfmt/archive/${fnlfmt_version}.tar.gz | tar -xzf - \
    && make -C fnlfmt-${fnlfmt_version} \
    && mv fnlfmt-${fnlfmt_version}/fnlfmt ~/.local/bin \
    && rm -rf fnlfmt-${fnlfmt_version}
