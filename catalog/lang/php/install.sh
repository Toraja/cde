#!/bin/bash
set -eo pipefail

sudo apt-get update
sudo apt-get upgrade --no-install-recommends --yes
sudo apt-get install --no-install-recommends --yes \
    pkg-config \
    build-essential \
    autoconf \
    bison \
    re2c \
    libxml2-dev \
    libsqlite3-dev

source ${HOME}/.asdf/asdf.sh
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
# phpactor is installed via vim's plugin manager since phpactor is likely to cause
# conflicts with other packages.
