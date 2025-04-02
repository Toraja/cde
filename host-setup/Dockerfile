FROM ubuntu:latest

RUN yes | unminimize

RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    sudo less man-db locales curl ca-certificates lsb-release bash-completion git openssh-client  && \
    locale-gen en_US.UTF-8
RUN curl --proto '=https' --tlsv1.2 --fail --silent --show-error https://just.systems/install.sh | bash -s -- --to /usr/local/bin && \
    just --completions bash > /etc/bash_completion.d/just

ARG UID
ARG USER
RUN : ${UID:?not defined} && \
    useradd --create-home --uid "${UID}" "${USER}" && \
    echo "%"${USER}" ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}

ENV PATH="${PATH}:/home/${USER}/.local/bin"
USER ${USER}
COPY --chown=${USER}:${USER} ./ /home/${USER}/wd/
WORKDIR /home/${USER}/wd/

RUN just prerequisite
