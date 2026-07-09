#!/bin/bash

set -e

mkdir --parents ~/.config/lazygit/
ln --symbolic --force ~/toybox/lazygit/config.yml ~/.config/lazygit/
