ARG BASE_IMAGE_TAG

FROM rust:latest AS taskwarrior

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# upgrading tzdata will fail because a relate file is bind-mounted
RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    make cmake gcc g++ uuid-dev jq && \
    rm --recursive --force /var/lib/apt/lists/*

# taskwarrior is installed at /usr/local/bin/task
RUN version=$(curl --silent https://api.github.com/repos/GothenburgBitFactory/taskwarrior/releases/latest | jq --raw-output '.tag_name') && \
    git clone --depth 1 --branch $version https://github.com/GothenburgBitFactory/taskwarrior.git /taskwarrior && \
    cd /taskwarrior && \
    cmake -DCMAKE_BUILD_TYPE=release -DENABLE_SYNC=OFF . && \
    make && \
    make install && \
    rm --recursive --force /taskwarrior

FROM ubuntu:${BASE_IMAGE_TAG}

# `unminimize` is required to use `man`
RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    unminimize \
    && yes | unminimize

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.
# Set up to install docker
ARG DOCKER_GROUP_ID
RUN apt-get update && apt-get install --no-install-recommends --yes \
    apt-transport-https ca-certificates curl gnupg lsb-release \
    && install --mode 0755 --directory /etc/apt/keyrings \
    && curl --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --output /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install --no-install-recommends --yes \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && rm --recursive --force /var/lib/apt/lists/* \
    # Specify GROUP_ID for docker as it differs depending on the environment (Docker Desktop etc.) \
    && groupmod --gid ${DOCKER_GROUP_ID} docker

# Must-have basic packages
## gettext-base installs envsubst
RUN apt-get update && apt-get install --no-install-recommends --yes \
        software-properties-common \
    && apt-add-repository ppa:fish-shell/release-4 \
    && apt-add-repository ppa:git-core/ppa \
    && apt-get update && apt-get install --no-install-recommends --yes \
        sudo less man-db locales tree openssh-client unzip wget gettext-base pipx \
        git git-lfs make xclip net-tools netcat-openbsd dnsutils fish vim tmux \
    && rm --recursive --force /var/lib/apt/lists/* \
    # Without this, `man` complains that $LC_* is not set \
    && locale-gen en_US.UTF-8

ARG USER_ID
ARG USER_NAME
ARG GROUP_ID
ARG GROUP_NAME
RUN userdel --remove ubuntu && \
    groupadd --gid ${GROUP_ID} ${GROUP_NAME} && \
    useradd --create-home --uid ${USER_ID} --gid ${GROUP_ID} --groups ${DOCKER_GROUP_ID} --shell /usr/bin/fish ${USER_NAME} && \
    echo ${USER_NAME}" ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME}

# Other nice-to-have tools
RUN apt-get update && apt-get install --no-install-recommends --yes \
        # file required by yazi, jq required by github-latest-release-installer \
        keychain file skopeo jq pwgen \
    && rm --recursive --force /var/lib/apt/lists/*

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

COPY --chown=${USER_NAME}:${USER_NAME} ./home ./
ENV PATH="/home/${USER_NAME}/.local/bin:${PATH}"

# Setup tools installed by apt
# toybox is cloned here as some of them requires it for setup
RUN mkdir --parents ~/tmp && \
    git clone --depth 1 https://github.com/Toraja/toybox.git && \
    # fish \
    mkdir --parents ~/.config/fish/completions/ ~/.config/fish/conf.d && \
    ln --symbolic ~/toybox/fish/functions ~/.config/fish/myfuncs && \
    ln --symbolic ~/toybox/fish/conf.d/* ~/.config/fish/conf.d/ && \
    _fisher-install.fish && \
    # git \
    mkdir --parents ~/.config/git && \
    ln --symbolic ~/toybox/git/gitignore_global ~/.config/git/ignore && \
    ln --symbolic ~/toybox/git/custom-commands/bin/* ~/.local/bin/ && \
    ln --symbolic ~/toybox/git/custom-commands/config/fish/* ~/.config/fish/conf.d/ && \
    # pipx \
    register-python-argcomplete --shell fish pipx > ~/.config/fish/completions/pipx.fish && \
    # tmux: tmp's install_plugins requires tmux.conf in toybox which is sourced from $XDG_CONFIG_HOME/tmux/tmux.conf \
    git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm && \
    ~/.config/tmux/plugins/tpm/bin/install_plugins && \
    mkdir --parents ~/.cde/mnt/single/.local/share/tmux/resurrect/ ~/.local/share/tmux/ && \
    ln --symbolic --force ~/.cde/mnt/single/.local/share/tmux/resurrect ~/.local/share/tmux/

RUN for p in httpie glances; do pipx install $p; done

RUN curl https://mise.run | sh && \
    mise completion fish > ~/.config/fish/completions/mise.fish && \
    mise activate fish > ~/.config/fish/conf.d/mise.fish

COPY --from=catalog lang/lua /tmp/catalog/lua
COPY --from=catalog ansible /tmp/catalog/ansible
RUN --mount=type=secret,id=GITHUB_TOKEN,env=GITHUB_TOKEN \
    for installer in /tmp/catalog/*/install.sh; do $installer; done && \
    mise install && \
    sudo rm --recursive --force /tmp/catalog

# taskwarrior
COPY --from=taskwarrior --chown=${USER_NAME}:${USER_NAME} /usr/local/bin/task /home/${USER_NAME}/.local/bin/task
RUN github-latest-release-installer.sh -t kdheepak taskwarrior-tui taskwarrior-tui-x86_64-unknown-linux-gnu.tar.gz ~/.local/bin && \
    # taskwarrior \
    mkdir --parents ~/.local/share/taskwarrior/ && \
    ln --symbolic ~/hosthome/.local/share/taskwarrior/task ~/.local/share/taskwarrior/task && \
    # tasktnote \
    mkdir --parents ~/.local/share/taskopen/ && \
    ln --symbolic ~/toybox/taskwarrior/tasknote ~/.local/bin/tasknote && \
    ln --symbolic ~/hosthome/.local/share/taskopen/notes ~/.local/share/taskopen/notes

# misc setup
RUN \
    # Remove toybox here as some of the tools installed by mise expect toybox to setup \
    rm --recursive --force ~/toybox && \
    # Setup symlink to host home directory to reduce bind mount \
    # This also enables replacing those links with actual files when symlink is inappriate \
    ln --symbolic ~/hosthome/.ssh ~/.ssh && \
    mkdir --parents ~/.docker && ln --symbolic ~/hosthome/.docker/config.json ~/.docker/config.json && \
    ln --symbolic ~/workspace/personal.github.com/Toraja/toybox ~/toybox && \
    # Create directories for volume mount destination so that owner:group of those directories are not root \
    mkdir --parents ~/.cde/mnt/single ~/.local/share/fish

CMD ["tail", "-f", "/dev/null"]
