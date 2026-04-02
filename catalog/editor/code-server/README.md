# code-server

## Setup

### Build

Add below to `docker-bake.hcl`.

```hcl
variable "CODE_SERVER_BIND_ADDR" {
  default = "127.0.0.1:8080"
}
variable "CODE_SERVER_CERT" {
  default = "false"
}
variable "CODE_SERVER_COPILOT_CHAT_VERSION" {
  default = "latest"
}

target "<target>" {
  args = {
    CODE_SERVER_BIND_ADDR = CODE_SERVER_BIND_ADDR
    CODE_SERVER_CERT = CODE_SERVER_CERT
    CODE_SERVER_COPILOT_CHAT_VERSION = CODE_SERVER_COPILOT_CHAT_VERSION
  }
}
```

In your Dockerfile, set variable when running `install.sh`.

```dockerfile
ARG CODE_SERVER_BIND_ADDR
ARG CODE_SERVER_CERT
ARG CODE_SERVER_CODE_SERVER_COPILOT_CHAT_VERSION
RUN --mount=type=cache,id=apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=apt-cache,target=/var/lib/apt,sharing=locked \
    --mount=type=bind,from=catalog,source=editor/code-server,target=/tmp/catalog/code-server \
    CODE_SERVER_BIND_ADDR=${CODE_SERVER_BIND_ADDR} \
    CODE_SERVER_CERT=${CODE_SERVER_CERT} \
    CODE_SERVER_COPILOT_CHAT_VERSION=${CODE_SERVER_COPILOT_CHAT_VERSION} \
    /tmp/catalog/code-server/install.sh
```

Set appropriate values in `.env` file if necessary.
```env
CODE_SERVER_BIND_ADDR=0.0.0.0:443
CODE_SERVER_CERT=true
CODE_SERVER_COPILOT_CHAT_VERSION=x.y.z
```

## Usage

Justfile is added as `code-server` module in global scope.  
Password is autonatically set if you start code-server via just.
