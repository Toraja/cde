#!/bin/bash
set -eo pipefail

mkdir -p ${HOME}/go
source ${HOME}/.asdf/asdf.sh
asdf-global-installer.sh golang
go install mvdan.cc/gofumpt@latest
go install github.com/segmentio/golines@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install golang.org/x/tools/cmd/goimports@latest
go install golang.org/x/tools/cmd/gorename@latest
go install github.com/fatih/gomodifytags@latest
go install golang.org/x/tools/gopls@latest
go install github.com/cweill/gotests/...@latest
go install github.com/koron/iferr@latest
go install golang.org/x/tools/cmd/callgraph@latest
go install golang.org/x/tools/cmd/guru@latest
go install github.com/josharian/impl@latest
go install github.com/davidrjenni/reftools/cmd/fillstruct@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/onsi/ginkgo/v2/ginkgo@latest
go install github.com/kyoh86/richgo@latest
go install gotest.tools/gotestsum@latest
go install github.com/golang/mock/mockgen@latest
go install github.com/tmc/json-to-struct@latest
asdf reshim