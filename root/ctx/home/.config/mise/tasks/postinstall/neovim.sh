#!/bin/bash

set -e

mkdir --parents ~/.local/{share,state}/nvim/ ~/.cde/mnt/single/.local/state/nvim/shada/ ~/.cde/mnt/shared/.local/{share,state}/nvim/lazy/
ln --symbolic --force ~/.cde/mnt/single/.local/state/nvim/{shada,trust} ~/.local/state/nvim/
ln --symbolic --force ~/.cde/mnt/shared/.local/share/nvim/lazy ~/.local/share/nvim/
ln --symbolic --force ~/.cde/mnt/shared/.local/state/nvim/lazy ~/.local/state/nvim/
