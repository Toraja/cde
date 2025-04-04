#!/bin/bash

set -euo pipefail

script_dir=$(dirname "$0")
fixture_dir=$script_dir/fixtures

sudo apt-get update
sudo apt-get install --no-install-recommends --yes pipx
# Install ansible directly with pipx rather than with mise as I don't need to switch versions
# and want to minimise disk usage
pipx install --include-deps ansible

# Create shell directories
mkdir --parents ~/.bashrc.d ~/.local/share/bash-completion/completions/ ~/.config/fish/{completions,conf.d}

# Install mise
PATH="$HOME/.local/bin:$PATH" # mise is installed under ~/.local/bin
curl https://mise.run | sh
cp --recursive $fixture_dir/mise ~/.config/
mise completion bash > ~/.local/share/bash-completion/completions/mise.bash
mise activate bash > ~/.bashrc.d/mise.bash
mise completion fish > ~/.config/fish/completions/mise.fish
mise activate fish > ~/.config/fish/conf.d/mise.fish
mise install

# Setup bashrc
grep --quiet '# Added by host setup' ~/.bashrc || cat $fixture_dir/bashrc >> ~/.bashrc
