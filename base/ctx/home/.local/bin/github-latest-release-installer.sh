#!/bin/bash

set -euo pipefail

usage() {
    echo "USAGE:"
    echo "    $(basename $0) [-hx] GITHUB_USER GITHUB_REPONAME ASSET_NAME DESTINATION"
    echo "OPTIONS:"
    echo "    -x Make downloaded file executable"
}

executable=false

while getopts :hx opt; do
	case ${opt} in
		x)
			executable=true
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

download_url=$(curl -s https://api.github.com/repos/${github_user}/${github_reponame}/releases/latest \
    | jq -r '.assets[] | select( .name == '\"${asset_name}\"' ) | .browser_download_url')

curl -fsSL --create-dirs -o $destination $download_url

if $executable; then
    chmod +x $destination
fi
