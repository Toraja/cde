#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")
catalog_name=$(basename "$script_dir")
mise_install=false

if [ -f "$script_dir/${catalog_name}.toml" ]; then
  cp -- "$script_dir/${catalog_name}.toml" ~/.config/mise/conf.d/
  mise_install=true
fi
if ls "$script_dir/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/postinstall/"* ~/.config/mise/tasks/postinstall/
fi
if $mise_install; then
  mise install
fi

# --- Add other commands ---

sudo apt-get update
sudo apt-get install --no-install-recommends --yes \
  default-jre graphviz

curl --fail --silent --show-error --location https://code-server.dev/install.sh | sh

# code-server creates workspace file in /home/coder and it failes because /home is not writable to non-root user.
# There seems to be no option to change it, so as a workaround, create symbolic link to home directory.
sudo ln --symbolic ~ /home/coder

cp --recursive -- "$script_dir/.config" ~
cp --recursive -- "$script_dir/.local" ~

curl --fail --silent --show-error --location \
  "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/GitHub/vsextensions/copilot-chat/${COPILOT_CHAT_VERSION:-latest}/vspackage" |
  gunzip - --stdout > copilot-chat.vsix &&
  code-server --install-extension ./copilot-chat.vsix &&
  code-server --install-extension vadimcn.vscode-lldb &&
  code-server --install-extension asciidoctor.asciidoctor-vscode &&
  code-server --install-extension MermaidChart.vscode-mermaid-chart &&
  code-server --install-extension jebbs.plantuml &&
  rm copilot-chat.vsix
