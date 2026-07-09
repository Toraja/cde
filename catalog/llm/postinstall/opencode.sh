#!/bin/bash
set -eo pipefail

mkdir --parents ~/.config/opencode/
cp --force ~/toybox/opencode/opencode.jsonc ~/.config/opencode/
cp --force ~/toybox/opencode/tui.jsonc ~/.config/opencode/
