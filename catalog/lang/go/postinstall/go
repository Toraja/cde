#!/bin/bash
set -e

script_dir=$(dirname "$0")

if [[ -r $script_dir/go-extra ]]; then
  # Use extra script to override versions and install additional go tools.
  # It is recommended to pin versions only when it is strictly necessary (e.g. for compatibility reason),
  # as the specified versions might get obsolete quickly.
  # GOLANGCI_LINT_VERSION=v1.59.0
  # MOCKGEN_VERSION=v0.4.0
  source ${script_dir}/go-extra
fi

# go tools that go.nvim depends on but not installed here are below
# https://github.com/ray-x/go.nvim?tab=readme-ov-file#go-binaries-install-and-update
# - gorename: gorename is deprecated and gopls can rename
# - fillswitch: does not work
# - iferr: not needed
# - gofumpt, golines, gotestsum: installed with mise
mise exec go --command '\
  echo "=== installing goimports ===" && go install golang.org/x/tools/cmd/goimports@latest && \
  echo "=== installing gopls ===" && go install golang.org/x/tools/gopls@latest && \
  echo "=== installing callgraph ===" && go install golang.org/x/tools/cmd/callgraph@latest && \
  echo "=== installing govulncheck ===" && go install golang.org/x/vuln/cmd/govulncheck@latest && \
  echo "=== installing gomodifytags ===" && go install github.com/fatih/gomodifytags@latest && \
  echo "=== installing gotests ===" && go install github.com/cweill/gotests/...@latest && \
  echo "=== installing impl ===" && go install github.com/josharian/impl@latest && \
  echo "=== installing delve ===" && go install github.com/go-delve/delve/cmd/dlv@latest && \
  echo "=== installing ginkgo-v2 ===" && go install github.com/onsi/ginkgo/v2/ginkgo@latest && \
  echo "=== installing json-to-struct ===" && go install github.com/tmc/json-to-struct@latest && \
  echo "=== installing mockgen ===" && go install go.uber.org/mock/mockgen@latest && \
  echo "=== installing go-enum ===" && curl --location --silent --show-error --fail --output ~/.local/bin/go-enum "https://github.com/abice/go-enum/releases/latest/download/go-enum_$(uname -s)_$(uname -m)" && chmod 755 ~/.local/bin/go-enum'
