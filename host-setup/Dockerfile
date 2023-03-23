FROM ubuntu:latest

RUN yes | unminimize

RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    make sudo less man-db locales curl ca-certificates lsb-release bash-completion git openssh-client  && \
    locale-gen en_US.UTF-8

ARG UID
ARG USER
RUN : ${UID:?not defined} && \
    useradd --create-home --uid "${UID}" --shell /usr/bin/fish "${USER}" && \
    echo "%"${USER}" ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}

ENV PATH="${PATH}:/home/${USER}/.local/bin"
USER ${USER}
COPY --chown=${USER}:${USER} ./ /home/${USER}/wd/
WORKDIR /home/${USER}/wd/

RUN make prerequisite
