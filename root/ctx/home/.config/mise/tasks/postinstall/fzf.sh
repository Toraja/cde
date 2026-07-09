#!/bin/bash

set -e

mkdir --parents ~/.config/fish/conf.d/
mise exec fzf --command "fzf --fish > ~/.config/fish/conf.d/fzf.fish"
