ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

USER root

RUN pip install 'python-language-server[all]' pipenv
# pyenv?

ARG USER
USER ${USER}

CMD ["tail", "-f", "/dev/null"]
