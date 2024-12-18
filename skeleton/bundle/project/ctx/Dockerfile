FROM baseimage

USER root

# Do something that requires root privilege

ARG USER_NAME
USER ${USER_NAME}

COPY --from=catalog lang/go /tmp/catalog/go
RUN /tmp/catalog/go/install.sh

COPY --from=catalog lang/rust /tmp/catalog/rust
RUN /tmp/catalog/rust/install.sh

RUN sudo rm --recursive --force ${HOME}/catalog
