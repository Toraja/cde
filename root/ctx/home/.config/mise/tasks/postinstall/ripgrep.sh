#!/bin/bash

set -e

mkdir --parents ~/.local/share/man/man1/
mise exec ripgrep --command "rg --generate complete-fish > ~/.config/fish/completions/rg.fish && rg --generate man > ~/.local/share/man/man1/rg.1"
