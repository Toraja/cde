ARG GO_BASE_IMAGE_NAME
ARG GO_BASE_IMAGE_TAG
FROM ${GO_BASE_IMAGE_NAME}:${GO_BASE_IMAGE_TAG}

USER root

ARG GO_VERSION
ARG CPU_ARCH
RUN curl -fsSL -o go.tar.gz https://golang.org/dl/go${GO_VERSION}.linux-${CPU_ARCH}.tar.gz \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz

ARG USER
USER ${USER}
RUN mkdir -p ~/go
VOLUME /home/${USER}/go

CMD ["tail", "-f", "/dev/null"]
