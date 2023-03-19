FROM baseimage

USER root

RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    python3-venv
RUN pip install pyright pipenv
# pyenv?

ARG USER_NAME
USER ${USER_NAME}
