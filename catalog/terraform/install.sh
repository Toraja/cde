#!/bin/bash
set -eo pipefail

source ${HOME}/.asdf/asdf.sh
asdf-global-installer.sh terraform terraform-ls
