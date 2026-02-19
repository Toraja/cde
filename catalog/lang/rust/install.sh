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

workdir=/tmp/codelldb
mkdir --parents $workdir
github-latest-release-installer.sh vadimcn codelldb 'codelldb-linux-x64.vsix' $workdir/codelldb.vsix
unzip -o $workdir/codelldb.vsix -d $workdir
mv $workdir/extension.vsixmanifest $workdir/extension/.vsixmanifest
mkdir --parents ~/.local/share/code-server/extensions/
mv $workdir/extension ~/.local/share/code-server/extensions/vadimcn.vscode-lldb
rm --recursive --dir --force $workdir
