#!/bin/bash
set -eo pipefail

mkdir --parents ~/.config/opencode/
# opencode config might need to be localised (custom providers, mcps) while tui.jsonc does not
cp --force ~/toybox/opencode/opencode.jsonc ~/.config/opencode/
ln --symbolic ~/toybox/opencode/tui.jsonc ~/.config/opencode/
