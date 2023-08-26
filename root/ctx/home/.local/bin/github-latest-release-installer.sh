#!/bin/bash

set -euo pipefail

usage() {
    echo "USAGE: $(basename $0) [-htTx] GITHUB_USER GITHUB_REPONAME ASSET_NAME DESTINATION"
    echo "    DESTINATION is a path to output the downloaded file. If -t/T is specified, it is tread as directory into which tarball is extracted."
    echo "OPTIONS:"
    echo "    -s NUMBER   Equivalent of tar --strip-components"
    echo "    -t          Extract tarball into the destination. Mutually exclusive with -x."
    echo "    -T MEMBER   Extract only the selected file in the tarball into the destination. Mutually exclusive with -x."
    echo "    -x          Make downloaded file executable. Mutually exclusive with -t/T."
}

error() {
    echo -e "\e[31m$@\e[0m"
}

executable=false
untar=false
tar_member=
strip_components=false

while getopts :hs:tT:x opt; do
    case ${opt} in
        x)
            if $untar; then
                error "-$opt is mutually exclusive with -t/T"
                exit 1
            fi
            executable=true
            ;;
        s)
            untar=true
            strip_components=true
            strip_number=$OPTARG
            ;;
        t)
            if $executable; then
                error "-$opt is mutually exclusive with -x"
                exit 1
            fi
            untar=true
            ;;
        T)
            if $executable; then
                error "-$opt is mutually exclusive with -x"
                exit 1
            fi
            untar=true
            tar_member=$OPTARG
            ;;
        h)
            usage
            exit 0
            ;;
        :)
            error "-$OPTARG requires argument"
            usage
            exit 1
            ;;
        \?)
            error "Invalid option: -$OPTARG"
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))
unset OPTIND

if [[ $# -ne 4 ]]; then
    error "Not enough arguments"
    usage
    exit 1
fi

github_user=$1
github_reponame=$2
asset_name=$3
destination=$4

download_url=$(curl -sSL https://api.github.com/repos/${github_user}/${github_reponame}/releases/latest \
    | jq --raw-output '.assets[] | select( .name | match ("^'${asset_name}'$") ) | .browser_download_url')
if [[ -z "$download_url" ]]; then
    error 'Failed to get download URL.'
    exit 1
fi

curl_cmd='curl -fsSL'
tar_cmd='tar xzf -'
if $strip_components; then
    tar_cmd="$tar_cmd --strip-components=$strip_number"
fi
if $untar; then
    mkdir --parents $destination
    $curl_cmd $download_url | $tar_cmd --directory $destination $tar_member
else
    $curl_cmd --create-dirs --output $destination $download_url
fi

if $executable; then
    chmod +x $destination
fi
