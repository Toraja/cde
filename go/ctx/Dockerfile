ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG USER
USER ${USER}

SHELL ["/bin/bash", "-c"]
RUN mkdir -p ~/go \
    && source ~/.asdf/asdf.sh \
    && asdf-global-installer.sh golang \
    && go install github.com/kyoh86/richgo@latest \
    && go install github.com/cweill/gotests/...@latest
VOLUME /home/${USER}/go
SHELL ["/bin/sh", "-c"]
