ARG IMAGE_TAG
FROM ubuntu:${IMAGE_TAG:-latest}

RUN yes | unminimize

RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    sudo less man-db locales curl ca-certificates lsb-release bash-completion git openssh-client  && \
    locale-gen en_US.UTF-8

ARG UID
ARG USER
ARG GROUP_NAME
RUN : ${UID:?not defined} && \
    useradd --create-home --uid "${UID}" "${USER}" && \
    echo "%"${USER}" ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}

ENV USER="${USER}"
USER ${USER}
COPY --chown=${USER}:${GROUP_NAME} ./ /home/${USER}/wd/
WORKDIR /home/${USER}/wd/

RUN ./first-step.sh
