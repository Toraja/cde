#!/bin/bash
set -eo pipefail

export PATH="$HOME/.asdf/shims:$PATH"
asdf-global-installer.sh terraform terraform-ls
