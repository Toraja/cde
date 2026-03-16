#!/bin/bash

set -e

mkdir --parents ~/.config/fish/completions/ ~/.local/share/man/man1/
mise exec xh --command "xh --generate complete-fish > ~/.config/fish/completions/xh.fish && xh --generate man > ~/.local/share/man/man1/xh.1"
