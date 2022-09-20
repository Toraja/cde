ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

USER root

RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    python3-venv
RUN pip install pyright pipenv
# pyenv?

ARG USER
USER ${USER}
