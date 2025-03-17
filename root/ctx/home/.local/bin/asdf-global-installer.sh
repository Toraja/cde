#!/bin/bash

set -eo pipefail

if [[ $# -eq 0 ]]; then
    cat <<EOF
Usage:
  $(basename $0) <plugin name[:version]> [plugin name[:version]...]
EOF
    exit 1
fi

for plugin in $@; do
    readarray -d ':' -t pluginfo <<< $plugin
    plugin_name=${pluginfo[0]}
    if [[ ${#pluginfo[@]} -ge 2 ]]; then
        plugin_ver=${pluginfo[1]}
    else
        plugin_ver=latest
    fi

    # force successful exit in case the plugin has already been added
    asdf plugin add $plugin_name || true
    asdf install $plugin_name $plugin_ver
    asdf set --home $plugin_name $plugin_ver
done
