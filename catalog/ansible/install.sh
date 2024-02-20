#!/bin/bash
set -eo pipefail

pipx install --include-deps ansible
pipx inject --include-apps ansible ansible-lint
