#!/bin/bash

set -e

mkdir --parents ~/.cde/mnt/single/.local/share/direnv/ ~/.config/fish/conf.d/ ~/.local/share/
ln --symbolic --force ~/.cde/mnt/single/.local/share/direnv ~/.local/share/
mise exec direnv --command "direnv hook fish > ~/.config/fish/conf.d/direnv.fish"
