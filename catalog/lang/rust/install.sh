#!/bin/bash
set -eo pipefail

# TODO: is it possible to override rust version in mise.toml?
# rust_version=${1:-latest}

sudo apt-get update
# pkg-config: required by rust-openssl crate which reqwest crate depends on
sudo apt-get install --no-install-recommends --yes \
  build-essential \
  pkg-config

script_dir=$(dirname "$0")
catalog_name=$(basename "$script_dir")

if [ -f "$script_dir/${catalog_name}.toml" ]; then
  cp -- "$script_dir/${catalog_name}.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/postinstall/"* ~/.config/mise/tasks/postinstall/
fi
mise install

# required by nvim-neotest
mise exec rust cargo-binstall --command 'cargo binstall cargo-nextest --secure'

# Used by rustaceanvim
nvim_vscode_extension_dir=~/.local/share/nvim/vscode-extensions
workdir=/tmp/codelldb
mkdir --parents $nvim_vscode_extension_dir $workdir
github-latest-release-installer.sh vadimcn codelldb 'codelldb-linux-x64.vsix' $workdir/codelldb.vsix
unzip -o $workdir/codelldb.vsix -d $workdir
mv $workdir/extension.vsixmanifest $workdir/extension/.vsixmanifest
# Usually the directory name is vadimcn.vscode-lldb-<version>, but it is hard to determine the version, so just use vadimcn.vscode-lldb
mv $workdir/extension $nvim_vscode_extension_dir/vadimcn.vscode-lldb
rm --recursive --dir --force $workdir

# cargo-release fails to install with mise
mise exec rust cargo-binstall --command 'cargo binstall --no-comfirm cargo-release'
