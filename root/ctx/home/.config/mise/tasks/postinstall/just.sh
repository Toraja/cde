#!/bin/bash

set -e

mkdir --parents ~/.local/share/man/man1/
mise exec just --command "just --completions fish > ~/.config/fish/completions/just.fish && just --man > ~/.local/share/man/man1/just.1"
