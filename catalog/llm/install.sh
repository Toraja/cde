#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
cp -- $script_dir/llm.toml ~/.config/mise/conf.d/
# cp -- $script_dir/llm ~/.config/mise/tasks/postinstall/

# Install specify-cli with `mise exec` since `uv` is supposed to be installed in python catalog
mise exec uv --command "uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
