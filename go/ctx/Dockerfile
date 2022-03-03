ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG USER
USER ${USER}
RUN mkdir -p ~/go \
    && bash -c '. ~/.asdf/asdf.sh \
    && asdf plugin-add golang && asdf install golang latest && asdf global golang latest'
VOLUME /home/${USER}/go

CMD ["tail", "-f", "/dev/null"]
