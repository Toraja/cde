FROM baseimage

ARG USER_NAME
USER ${USER_NAME}

COPY --from=catalog go /tmp/catalog/
RUN /tmp/catalog/go/install.sh

COPY --from=catalog rust /tmp/catalog/
RUN /tmp/catalog/rust/install.sh

RUN sudo rm -rf ${HOME}/catalog
