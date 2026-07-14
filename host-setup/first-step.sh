#!/bin/bash

set -euo pipefail

script_dir=$(dirname "$0")
fixture_dir=$script_dir/fixtures

set -a
${script_dir}/../.env
set +a

# Create shell directories
mkdir --parents ~/.bashrc.d ~/.local/share/bash-completion/completions/ ~/.config/fish/{completions,conf.d}

# Setup bashrc
grep --quiet '# Added by host setup' ~/.bashrc || cat $fixture_dir/bashrc >> ~/.bashrc

# Install mise
PATH="$HOME/.local/bin:$PATH" # mise is installed under ~/.local/bin
curl --location --silent --show-error --fail --retry 5 --retry-delay 3 https://mise.run | sh
cp --recursive $fixture_dir/mise ~/.config/
mise completion --include-bash-completion-lib bash > ~/.local/share/bash-completion/completions/mise.bash
mise activate bash > ~/.bashrc.d/mise.bash
cp --recursive $fixture_dir/fish ~/.config/
mise completion fish > ~/.config/fish/completions/mise.fish
mise install

# Source bashrc (including mise.bash) to avoid re-login
. ~/.bashrc
