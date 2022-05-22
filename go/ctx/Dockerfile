ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG USER
USER ${USER}
RUN mkdir -p ~/go \
    && bash -c '. ~/.asdf/asdf.sh \
    && ~/.local/bin/asdf-global-installer.sh \
        golang \
    && go install github.com/kyoh86/richgo@latest'
VOLUME /home/${USER}/go
