ARG BASE_IMAGE_TAG

FROM rust:latest AS taskwarrior

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    make cmake gcc g++ uuid-dev && \
    rm --recursive --force /var/lib/apt/lists/*

# taskwarrior is installed at /usr/local/bin/task
RUN git clone --depth 1 --branch v3.2.0 https://github.com/GothenburgBitFactory/taskwarrior.git /taskwarrior && \
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
    && apt-add-repository ppa:fish-shell/release-3 \
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
        # these required by asdf \
        dirmngr gpg curl gawk \
    && rm --recursive --force /var/lib/apt/lists/* \
    && curl --fail --silent --show-error --location https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | DIR=/usr/local/bin bash

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

COPY --chown=${USER_NAME}:${USER_NAME} ./home ./
ENV PATH="/home/${USER_NAME}/.local/bin:${PATH}"

COPY --chown=${USER_NAME}:${USER_NAME} ./helpers/install-fish-plugins.fish /home/${USER_NAME}/.local/bin/
RUN mkdir --parents ~/tmp && mkdir --parents ~/.config/fish/completions/ \
    && for p in httpie glances yamllint; do pipx install $p; done \
    && github-latest-release-installer.sh -T yamlfmt google yamlfmt 'yamlfmt_.*_Linux_x86_64.tar.gz' ~/.local/bin/ \
    && yazi_tmp=/tmp/yazi \
    && github-latest-release-installer.sh sxyazi yazi 'yazi-x86_64-unknown-linux-gnu.zip' ${yazi_tmp}/yazi.zip \
    && unzip -d ${yazi_tmp} ${yazi_tmp}/yazi.zip \
    && mv ${yazi_tmp}/yazi-x86_64-unknown-linux-gnu/{yazi,ya} ~/.local/bin \
    && mv ${yazi_tmp}/yazi-x86_64-unknown-linux-gnu/completions/{yazi,ya}.fish ~/.config/fish/completions/ \
    && rm --recursive --force ${yazi_tmp}

COPY --chown=${USER_NAME}:${USER_NAME} ./helpers/install-asdf-plugins.sh /home/${USER_NAME}/.local/bin/
RUN asdf_version=$(curl --silent https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq --raw-output '.tag_name') \
    && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${asdf_version} \
    && ln --symbolic ~/.asdf/completions/asdf.fish ~/.config/fish/completions/ \
    && install-asdf-plugins.sh

COPY --from=catalog lang/lua /tmp/catalog/lua
COPY --from=catalog ansible /tmp/catalog/ansible
COPY --from=catalog lang/toml /tmp/catalog/toml
RUN for installer in /tmp/catalog/*/install.sh; do $installer; done && \
    sudo rm --recursive --force /tmp/catalog

# taskwarrior
COPY --from=taskwarrior --chown=${USER_NAME}:${USER_NAME} /usr/local/bin/task /home/${USER_NAME}/.local/bin/task
RUN github-latest-release-installer.sh -t kdheepak taskwarrior-tui taskwarrior-tui-x86_64-unknown-linux-gnu.tar.gz ~/.local/bin

# Setup tools
RUN git clone https://github.com/Toraja/toybox.git \
    # fish \
    && install-fish-plugins.fish \
    && ln --symbolic ~/toybox/fish/functions ~/.config/fish/myfuncs \
    && ln --symbolic ~/toybox/fish/conf.d/* ~/.config/fish/conf.d/ \
    && mkdir --parents ~/.cde/mnt/single/.local/share/fish/ \
    && ln --symbolic --force ~/.cde/mnt/single/.local/share/fish/fish_history ~/.local/share/fish/ \
    # git \
    && mkdir --parents ~/.config/git \
    && ln --symbolic ~/toybox/git/gitignore_global ~/.config/git/ignore \
    && ln --symbolic ~/toybox/git/custom-commands/bin/* ~/.local/bin/ \
    && ln --symbolic ~/toybox/git/custom-commands/config/fish/* ~/.config/fish/conf.d/ \
    # gh \
    && ln --symbolic ~/hosthome/.config/gh ~/.config/gh \
    # pipx \
    && register-python-argcomplete --shell fish pipx > ~/.config/fish/completions/pipx.fish \
    # lazygit \
    && mkdir --parents ~/.config/lazygit/ && ln --symbolic ~/toybox/lazygit/config.yml ~/.config/lazygit/ \
    # tmux \
    && git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm \
    && ~/.config/tmux/plugins/tpm/bin/install_plugins \
    && mkdir --parents ~/.cde/mnt/single/.local/share/tmux/resurrect/ ~/.local/share/tmux/ \
    && ln --symbolic --force ~/.cde/mnt/single/.local/share/tmux/resurrect ~/.local/share/tmux/ \
    # yazi \
    && mkdir --parents ~/.config/yazi/plugins \
    && ln --symbolic ~/toybox/yazi/*.{lua,toml} ~/.config/yazi/ \
    && ya pack -a yazi-rs/plugins:smart-enter \
    && ya pack -a yazi-rs/plugins:full-border \
    && ya pack -a yazi-rs/plugins:smart-filter \
    && ya pack -a yazi-rs/plugins:chmod \
    && ya pack -a yazi-rs/plugins:git \
    && ya pack -a yazi-rs/plugins:max-preview \
    && ya pack -a yazi-rs/plugins:hide-preview \
    # taskwarrior \
    && mkdir --parents ~/.local/share/taskwarrior/ \
    && ln --symbolic ~/hosthome/.local/share/taskwarrior/task ~/.local/share/taskwarrior/task \
    # tasktnote \
    && mkdir --parents ~/.local/share/taskopen/ \
    && ln --symbolic ~/toybox/taskwarrior/tasknote ~/.local/bin/tasknote \
    && ln --symbolic ~/hosthome/.local/share/taskopen/notes ~/.local/share/taskopen/notes \
    # yamlfmt & yamllint \
    && ln --symbolic ~/toybox/{yamlfmt,yamllint} ~/.config/

# Setup symlink to host home directory to reduce bind mount
# This also enables replacing those links with actual files when symlink is inappriate
RUN rm --recursive --force ~/toybox \
    && ln --symbolic ~/hosthome/.ssh ~/.ssh \
    && mkdir --parents ~/.docker && ln --symbolic ~/hosthome/.docker/config.json ~/.docker/config.json \
    && ln --symbolic ~/workspace/personal.github.com/Toraja/toybox ~/toybox

# Create directories for volume mount destination so that owner:group of those directories are not root.
RUN mkdir --parents ~/.local/{share,state}
RUN mkdir --parents ~/.cde/mnt/single/.local/{share,state}

CMD ["tail", "-f", "/dev/null"]
