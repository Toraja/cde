# code-server

## Setup

### Build

Add below to `docker-bake.hcl`.

```hcl
variable "COPILOT_CHAT_VERSION" {
  default = "latest"
}

target "<target>" {
  args = {
    COPILOT_CHAT_VERSION = COPILOT_CHAT_VERSION
  }
}
```

In your Dockerfile, set variable when running `install.sh`.

```dockerfile
ARG COPILOT_CHAT_VERSION
RUN --mount=type=cache,id=apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=apt-cache,target=/var/lib/apt,sharing=locked \
    --mount=type=bind,from=catalog,source=editor/code-server,target=/tmp/catalog/code-server \
	COPILOT_CHAT_VERSION=${COPILOT_CHAT_VERSION} /tmp/catalog/code-server/install.sh
```

Set `COPILOT_CHAT_VERSION` in `.env` file if you need to specify the extension version.
```env
COPILOT_CHAT_VERSION=x.y.z
```

## Usage

Password must be passed via flag or manually added to config file.

```sh
code-server --password PASSWORD
```

Or, add below recipes to your global justfile to automatically generate password if it is not present in the config file.

```just
code_server_port := env("CODE_SERVER_PORT", "443")

code-server: code-server-pass
	code-server --bind-addr 0.0.0.0:{{code_server_port}} --disable-workspace-trust

code-server-pass:
	#!/bin/bash
	if [ "$(yq '.password' ~/.config/code-server/config.yaml)" = "null" ]; then
		yq -i '.password = "'"$(openssl rand -base64 32 | tr -d '/+=' | head -c 32)"'"' ~/.config/code-server/config.yaml
		echo "Password added to ~/.config/code-server/config.yaml"
	fi
	echo Password: $(yq '.password' ~/.config/code-server/config.yaml)
```
