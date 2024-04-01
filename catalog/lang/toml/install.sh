#!/bin/bash
set -eo pipefail

# github-latest-release-installer.sh tamasfe taplo 'taplo-linux-x86_64.gz' /tmp/taplo.gz
# NOTE: taple 0.9.0 does not have assets and hence fails to install.
curl -o /tmp/taplo.gz -fsSL https://github.com/tamasfe/taplo/releases/download/0.8.1/taplo-linux-x86_64.gz
gunzip /tmp/taplo.gz
chmod 755 /tmp/taplo
mv /tmp/taplo ~/.local/bin/
