# Simply assigning default value in ARG instruction does not work, maybe because an environment variable
# with the same name is defined in compose file...  So use variable substitution instead.
ARG BASE_IMAGE_TAG
FROM ubuntu:${BASE_IMAGE_TAG:-rolling}

# `unminimize` is required to use `man`
RUN yes | unminimize
# Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.
# Set up to install docker
ARG CPU_ARCH
ARG DOCKER_GID
RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    apt-transport-https ca-certificates curl gnupg lsb-release \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch="${CPU_ARCH}" signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install --no-install-recommends --yes \
        docker-ce docker-ce-cli containerd.io \
    && rm -rf /var/lib/apt/lists/* \
    # Specify GID for docker as it differs depending on the environment (Docker Desktop etc.) \
    && groupmod --gid ${DOCKER_GID} docker

# Must-have basic packages
## gettext-base installs envsubst
## build-essential is required by lua
RUN apt-get update && apt-get install --no-install-recommends --yes \
        software-properties-common \
    && apt-add-repository ppa:fish-shell/release-3 \
    && apt-get update && apt-get install --no-install-recommends --yes \
        sudo less man-db locales tree openssh-client unzip wget gettext-base \
        python3-pip build-essential \
        git git-lfs make xclip net-tools netcat fish vim tmux \
    && rm -rf /var/lib/apt/lists/* \
    # Without this, `man` complains that $LC_* is not set \
    && locale-gen en_US.UTF-8

ARG UID
ARG USER
RUN useradd --create-home --uid ${UID} --groups docker --shell /usr/bin/fish ${USER} \
    && echo "%"${USER}" ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}

# Other nice-to-have tools
RUN apt-get update && apt-get install --no-install-recommends --yes \
        # file required by ranger \
        keychain jq ripgrep file ranger \
        # these required by asdf \
        dirmngr gpg curl gawk \
    && rm -rf /var/lib/apt/lists/* \
    && pip install httpie glances ansible yamllint \
    && curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | DIR=/usr/local/bin bash

# vim plugin related
RUN apt-get update && apt-get install --no-install-recommends --yes \
        # TagBar: universal-ctags \
        # telescope-fzf-native.nvim: gcc \
        universal-ctags gcc \
    && rm -rf /var/lib/apt/lists/* \
    # pynvim is required by python plugins \
    && pip install pynvim

USER ${USER}
WORKDIR /home/${USER}

COPY --chown=${USER}:${USER} ./home ./
ENV PATH="/home/${USER}/.local/bin:${PATH}"

COPY --chown=${USER}:${USER} ./helpers/install-fish-plugins.fish /home/${USER}/.local/bin/
RUN \
    mkdir -p ~/tmp \
    # Create directory for volume so that owner will be the ${USER} \
    && mkdir -p ~/.cache ~/.local/share/nvim/site \
    # others \
    && github-latest-release-installer.sh -x docker compose docker-compose-linux-x86_64 ~/.docker/cli-plugins/docker-compose \
    && github-latest-release-installer.sh -t sumneko lua-language-server 'lua-language-server-.*-linux-x64.tar.gz' ~/.local/opt/lua-language-server/

COPY --chown=${USER}:${USER} ./helpers/install-asdf-plugins.sh /home/${USER}/.local/bin/
ENV PATH="/home/${USER}/.krew/bin:$PATH"
ARG ASDF_VERSION
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION} \
    && mkdir -p ~/.config/fish/completions/ \
    && ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions/ \
    && install-asdf-plugins.sh

# Setup tools
RUN git clone https://github.com/Toraja/toybox.git \
    # fish \
    && install-fish-plugins.fish \
    && ln -s ~/toybox/fish/functions ~/.config/fish/myfuncs \
    && ln -s ~/toybox/fish/conf.d/* ~/.config/fish/conf.d/ \
    # git \
    && ln -s ~/toybox/git/gitignore_global ~/.gitignore_global \
    && ln -s ~/toybox/git/custom-commands/bin/* ~/.local/bin/ \
    && ln -s ~/toybox/git/custom-commands/config/fish/* ~/.config/fish/conf.d/ \
    # tmux \
    && git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm \
    && ~/.config/tmux/plugins/tpm/bin/install_plugins

# Setup symlink to host home directory to reduce bind mount
# This also enables replacing those links with actual files when symlink is inappriate
RUN rm -rf ~/toybox \
    && ln -s ~/hosthome/.ssh ~/.ssh \
    && ln -s ~/hosthome/.docker/config.json ~/.docker/config.json \
    && ln -s ~/workspace/personal.github.com/Toraja/toybox ~/toybox

CMD ["tail", "-f", "/dev/null"]
