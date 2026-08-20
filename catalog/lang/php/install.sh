#!/bin/bash
set -eo pipefail

sudo apt-get update
# List of dependencies taken from https://github.com/jdx/mise/discussions/4720#discussioncomment-12627273
sudo apt-get install --no-install-recommends --yes \
    autoconf \
    bison \
    build-essential \
    curl \
    gettext \
    git \
    libgd-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libicu-dev \
    libjpeg-dev \
    libmysqlclient-dev \
    libonig-dev \
    libpng-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    openssl \
    pkg-config \
    re2c \
    zlib1g-dev

composer global require --dev \
    emielmolenaar/phpcs-laravel \
    friendsofphp/php-cs-fixer \
    nunomaduro/larastan \
    phpstan/phpstan \
    phpmd/phpmd \
    squizlabs/php_codesniffer

ghrls download --output ~/.local/bin/phpactor --executable https://github.com/phpactor/phpactor phpactor.phar
