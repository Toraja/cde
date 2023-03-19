FROM baseimage

USER root

RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    build-essential gdb \
    && rm -rf /var/lib/apt/lists/*

ARG USER_NAME
USER ${USER_NAME}

SHELL ["/bin/bash", "-c"]
RUN source ~/.asdf/asdf.sh \
    # protoc is required by rust-analyzer \
    && asdf-global-installer.sh rust rust-analyzer protoc \
    && rustup completions fish > ~/.config/fish/completions/rustup.fish \
    && rustup component add rust-src rust-analysis rustfmt clippy \
    && curl -LsSf https://get.nexte.st/latest/linux | tar zxf - -C $(dirname $(asdf which cargo))
SHELL ["/bin/sh", "-c"]
