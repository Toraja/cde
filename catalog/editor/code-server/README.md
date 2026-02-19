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
