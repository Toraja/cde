#!/bin/bash

set -eo pipefail

if [[ $# -eq 0 ]]; then
    echo Argument is required.
    echo "$(basename (status --current-filename)) <plugin name[:version]> [plugin name[:version]...]"
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
    asdf plugin-add $plugin_name || true
    asdf install $plugin_name $plugin_ver
    asdf global $plugin_name $plugin_ver
done
