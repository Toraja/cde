#!/bin/bash

set -euo pipefail

usage() {
    echo "USAGE:"
    echo "    $(basename $0) [-hx] GITHUB_USER GITHUB_REPONAME ASSET_NAME DESTINATION"
    echo "OPTIONS:"
    echo "    -x Make downloaded file executable"
}

executable=false
untar=false

while getopts :htx opt; do
    case ${opt} in
        x)
            executable=true
            ;;
        t)
            untar=true
            ;;
        h)
            echo help
            usage
            exit 0
            ;;
        \?)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))
unset OPTIND

if [[ $# -ne 4 ]]; then
    usage
    exit 1
fi

github_user=$1
github_reponame=$2
asset_name=$3
destination=$4

download_url=$(curl https://api.github.com/repos/${github_user}/${github_reponame}/releases/latest \
    | jq -r '.assets[] | select( .name | match ("^'${asset_name}'$") ) | .browser_download_url')
if [[ -z "$download_url" ]]; then
    echo 'Failed to get download URL.'
    exit 1
fi

curl_cmd='curl -fsSL'
if $untar; then
    mkdir -p $destination
    $curl_cmd $download_url | tar xzf - -C $destination
else
    $curl_cmd --create-dirs -o $destination $download_url
fi

if $executable; then
    chmod +x $destination
fi
