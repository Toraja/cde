#!/bin/bash

set -e

rm --recursive --force ~/.config/cheat/cheatsheets/community
git clone --depth 1 https://github.com/cheat/cheatsheets.git ~/.config/cheat/cheatsheets/community
ln --symbolic --force ~/toybox/cheat/conf.yml ~/.config/cheat/conf.yml
ln --symbolic --force ~/toybox/cheat/cheatsheets ~/.config/cheat/cheatsheets/personal
mkdir --parents ~/.config/fish/completions/
mise exec cheat --command " cheat --completion fish > ~/.config/fish/completions/cheat.fish"
