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
# curl --location --silent --show-error --fail https://get.nexte.st/latest/linux | tar -zxf - --directory $(dirname $(asdf which cargo))
mise exec rust cargo-binstall --command 'cargo binstall cargo-nextest --secure'

# Used by rustaceanvim
code_server_extension_dir=~/.local/share/code-server/extensions
codelldb_path=$(find $code_server_extension_dir -mindepth 1 -maxdepth 1 -type d -name "vadimcn.vscode-lldb*" | head -1)
if [ -z "$codelldb_path" ]; then
  workdir=/tmp/codelldb
  mkdir --parents $workdir
  github-latest-release-installer.sh vadimcn codelldb 'codelldb-linux-x64.vsix' $workdir/codelldb.vsix
  unzip -o $workdir/codelldb.vsix -d $workdir
  mv $workdir/extension.vsixmanifest $workdir/extension/.vsixmanifest
  mkdir --parents $code_server_extension_dir
  # Usually the directory name is vadimcn.vscode-lldb-<version>, but it is hard to determine the version, so just use vadimcn.vscode-lldb
  mv $workdir/extension $code_server_extension_dir/vadimcn.vscode-lldb
  rm --recursive --dir --force $workdir
else
  ln --symbolic $codelldb_path $code_server_extension_dir/vadimcn.vscode-lldb
fi
