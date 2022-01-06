ARG RUST_BASE_IMAGE_NAME
ARG RUST_BASE_IMAGE_TAG
FROM ${RUST_BASE_IMAGE_NAME}:${RUST_BASE_IMAGE_TAG}

USER root

RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    build-essential gdb \
    && rm -rf /var/lib/apt/lists/*

ARG USER
USER ${USER}

ARG RUST_VERSION
ARG RUSTUP_HOME
ARG CARGO_HOME
ENV RUSTUP_HOME=${RUSTUP_HOME} \
    CARGO_HOME=${CARGO_HOME} \
    PATH=${CARGO_HOME}/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path --default-toolchain ${RUST_VERSION}; \
    rustup --version; \
    cargo --version; \
    rustc --version;
VOLUME /home/${USER}/rust

RUN rustup completions fish > ~/.config/fish/completions/rustup.fish \
    && rustup component add rls rust-src rust-analysis \
    && rustup +nightly component add rust-analyzer-preview

CMD ["tail", "-f", "/dev/null"]
