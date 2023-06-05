#!/bin/bash
set -eo pipefail

source ${HOME}/.asdf/asdf.sh
asdf-global-installer.sh \
    kubectl \
    kind \
    k9s \
    helm \
    helmfile

kubectl completion fish > ~/.config/fish/completions/kubectl.fish
kind completion fish > ~/.config/fish/completions/kind.fish
helm completion fish > ~/.config/fish/completions/helm.fish
helm plugin install https://github.com/databus23/helm-diff
k9s completion fish > ~/.config/fish/completions/k9s.fish

# install krew
TEMPDIR="$(mktemp -d)"
OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
KREW="krew-${OS}_${ARCH}"
curl -fsSL "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" | tar -xzf - --directory ${TEMPDIR}
"${TEMPDIR}/${KREW}" install krew
rm -rdf ${TEMPDIR}
kubectl krew install tree tail ns

echo 'fish_add_path ~/.krew/bin' >> ~/.config/fish/config.fish
