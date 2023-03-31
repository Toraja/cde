FROM baseimage

ARG USER_NAME
USER ${USER_NAME}

COPY --from=catalog go /home/${USER_NAME}/catalog/
RUN ${HOME}/catalog/go/install.sh

COPY --from=catalog rust /home/${USER_NAME}/catalog/
RUN ${HOME}/catalog/rust/install.sh

RUN sudo rm -rf ${HOME}/catalog
