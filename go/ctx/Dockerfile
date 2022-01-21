ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

USER root

ARG VERSION
ARG CPU_ARCH
RUN curl -fsSL -o go.tar.gz https://golang.org/dl/go${VERSION}.linux-${CPU_ARCH}.tar.gz \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz

ARG USER
USER ${USER}
RUN mkdir -p ~/go
VOLUME /home/${USER}/go

CMD ["tail", "-f", "/dev/null"]
