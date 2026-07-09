#!/bin/bash

set -e

mkdir --parents ~/.cde/mnt/shared/.config/gh
ln --symbolic --force ~/.cde/mnt/shared/.config/gh ~/.config/gh
mise exec github-cli --command "gh extension install dlvhdr/gh-dash"
