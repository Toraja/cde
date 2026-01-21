ARG IMAGE_TAG
# Use `latest` as the host is usually on LTS version
FROM ubuntu:${IMAGE_TAG:-latest}

RUN yes | unminimize

RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    sudo less man-db locales curl ca-certificates lsb-release bash-completion git openssh-client  && \
    locale-gen en_US.UTF-8

ARG USER_ID
ARG USER_NAME
ARG GROUP_ID
ARG GROUP_NAME
RUN userdel --remove ubuntu && \
    groupadd --gid ${GROUP_ID} ${GROUP_NAME} && \
    useradd --create-home --uid ${USER_ID} --gid ${GROUP_ID} ${USER_NAME} && \
    echo ${USER_NAME}" ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME}

# ENV USER="${USER}"
USER ${USER_NAME}
COPY --chown=${USER_NAME}:${GROUP_NAME} ./ /home/${USER_NAME}/wd/
WORKDIR /home/${USER_NAME}/wd/

RUN ./first-step.sh
