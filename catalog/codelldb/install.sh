#!/bin/bash
set -eo pipefail

dest=/tmp/codelldb
mkdir --parents $dest
github-latest-release-installer.sh vadimcn codelldb 'codelldb-x86_64-linux.vsix' $dest/codelldb.vsix
unzip -o $dest/codelldb.vsix -d $dest
mv $dest/extension.vsixmanifest $dest/extension/.vsixmanifest
mkdir --parents ~/.local/share/code-server/extensions/
mv $dest/extension ~/.local/share/code-server/extensions/vadimcn.vscode-lldb
rm --recursive --dir --force $dest
