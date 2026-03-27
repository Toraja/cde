#!/bin/bash

set -euo pipefail

script_dir=$(dirname "$0")
fixture_dir=$script_dir/fixtures

# Create shell directories
mkdir --parents ~/.bashrc.d ~/.local/share/bash-completion/completions/ ~/.config/fish/{completions,conf.d}

# Setup bashrc
grep --quiet '# Added by host setup' ~/.bashrc || cat $fixture_dir/bashrc >> ~/.bashrc

# Install mise
PATH="$HOME/.local/bin:$PATH" # mise is installed under ~/.local/bin
curl https://mise.run | sh
cp --recursive $fixture_dir/mise ~/.config/
mise completion --include-bash-completion-lib bash > ~/.local/share/bash-completion/completions/mise.bash
mise activate bash > ~/.bashrc.d/mise.bash
mise completion fish > ~/.config/fish/completions/mise.fish
mise install
