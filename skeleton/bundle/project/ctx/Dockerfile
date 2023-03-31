FROM baseimage

ARG USER_NAME
USER ${USER_NAME}

COPY --from=catalogs go /home/${USER_NAME}/catalogs/
RUN ${HOME}/catalogs/go/install.sh

COPY --from=catalogs rust /home/${USER_NAME}/catalogs/
RUN ${HOME}/catalogs/rust/install.sh

RUN sudo rm -rf ${HOME}/catalogs
