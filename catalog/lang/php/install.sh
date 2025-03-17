#!/bin/bash
set -eo pipefail

sudo apt-get update
sudo apt-get install --no-install-recommends --yes \
    pkg-config \
    build-essential \
    autoconf \
    bison \
    re2c \
    libxml2-dev \
    libsqlite3-dev

export PATH="$HOME/.asdf/shims:$PATH"
# XXX Installation fails with error: No package 'openssl' found
# Installing 'openssl' with apt-get does not solve it.
asdf-global-installer.sh php

composer global require --dev \
    emielmolenaar/phpcs-laravel \
    friendsofphp/php-cs-fixer \
    nunomaduro/larastan \
    phpstan/phpstan \
    phpmd/phpmd \
    squizlabs/php_codesniffer

github-latest-release-installer.sh -x phpactor phpactor phpactor.phar ~/.local/bin/phpactor
