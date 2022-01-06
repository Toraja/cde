ARG PYTHON_BASE_IMAGE_NAME
ARG PYTHON_BASE_IMAGE_TAG
FROM ${PYTHON_BASE_IMAGE_NAME}:${PYTHON_BASE_IMAGE_TAG}

USER root

RUN pip install 'python-language-server[all]' pipenv
# pyenv?

ARG USER
USER ${USER}

CMD ["tail", "-f", "/dev/null"]
