ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

USER root

RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    build-essential gdb \
    && rm -rf /var/lib/apt/lists/*

ARG USER
USER ${USER}

RUN bash -c '. ~/.asdf/asdf.sh \
    && asdf plugin-add rust && asdf install rust stable && asdf global rust stable \
    && rustup completions fish > ~/.config/fish/completions/rustup.fish \
    && rustup component add rls rust-src rust-analysis \
    && rustup +nightly component add rust-analyzer-preview'
