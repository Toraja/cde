#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
catalog_name=$(basename "$script_dir")

if [ -f "$script_dir/${catalog_name}.toml" ]; then
  cp -- "$script_dir/${catalog_name}.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/postinstall/"* ~/.config/mise/tasks/postinstall/
fi

dest=/tmp/codelldb
mkdir --parents $dest
github-latest-release-installer.sh vadimcn codelldb 'codelldb-linux-x64.vsix' $dest/codelldb.vsix
unzip -o $dest/codelldb.vsix -d $dest
mv $dest/extension.vsixmanifest $dest/extension/.vsixmanifest
mkdir --parents ~/.local/share/code-server/extensions/
mv $dest/extension ~/.local/share/code-server/extensions/vadimcn.vscode-lldb
rm --recursive --dir --force $dest
