#!/bin/bash
set -eo pipefail

github-latest-release-installer.sh tamasfe taplo 'taplo-linux-x86_64.gz' /tmp/taplo.gz
gunzip /tmp/taplo.gz
chmod 755 /tmp/taplo
mv taplo ~/.local/bin/
