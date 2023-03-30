# Simply assigning default value in ARG instruction does not work, maybe because an environment variable
# with the same name is defined in compose file...  So use variable substitution instead.
ARG BASE_IMAGE_TAG
FROM ubuntu:${BASE_IMAGE_TAG:-rolling}

# `unminimize` is required to use `man`
RUN yes | unminimize
# Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.
# Set up to install docker
ARG DOCKER_GROUP_ID
RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    apt-transport-https ca-certificates curl gnupg lsb-release \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install --no-install-recommends --yes \
        docker-ce docker-ce-cli containerd.io docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/* \
    # Specify GROUD_ID for docker as it differs depending on the environment (Docker Desktop etc.) \
    && groupmod --gid ${DOCKER_GROUP_ID} docker

# Must-have basic packages
## gettext-base installs envsubst
## build-essential is required by lua
RUN apt-get update && apt-get install --no-install-recommends --yes \
        software-properties-common \
    && apt-add-repository ppa:fish-shell/release-3 \
    && apt-add-repository ppa:git-core/ppa \
    && apt-get update && apt-get install --no-install-recommends --yes \
        sudo less man-db locales tree openssh-client unzip wget gettext-base \
        python3-pip build-essential \
        git git-lfs gh make xclip net-tools netcat-openbsd fish vim tmux \
    && rm -rf /var/lib/apt/lists/* \
    # Without this, `man` complains that $LC_* is not set \
    && locale-gen en_US.UTF-8

ARG USER_ID
ARG USER_NAME
ARG GROUD_ID
ARG GROUP_NAME
RUN groupadd --gid ${GROUD_ID} ${GROUP_NAME} \
    && useradd --create-home --uid ${USER_ID} --gid ${GROUD_ID} --groups ${DOCKER_GROUP_ID} --shell /usr/bin/fish ${USER_NAME} \
    && echo ${USER_NAME}" ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME}

# Other nice-to-have tools
RUN apt-get update && apt-get install --no-install-recommends --yes \
        # file required by ranger \
        keychain jq ripgrep file ranger skopeo \
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

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

COPY --chown=${USER_NAME}:${USER_NAME} ./home ./
ENV PATH="/home/${USER_NAME}/.local/bin:${PATH}"

COPY --chown=${USER_NAME}:${USER_NAME} ./helpers/install-fish-plugins.fish /home/${USER_NAME}/.local/bin/
RUN mkdir -p ~/tmp \
    && github-latest-release-installer.sh -x docker buildx 'buildx-v.*.linux-amd64'  ~/.docker/cli-plugins/docker-buildx \
    && github-latest-release-installer.sh -t LuaLS lua-language-server 'lua-language-server-.*-linux-x64.tar.gz' ~/.local/opt/lua-language-server/

COPY --chown=${USER_NAME}:${USER_NAME} ./helpers/install-asdf-plugins.sh /home/${USER_NAME}/.local/bin/
ENV PATH="/home/${USER_NAME}/.krew/bin:$PATH"
RUN asdf_version=$(curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq -r '.tag_name') \
    && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${asdf_version} \
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
    # gh \
    && ln -s ~/hosthome/.config/gh ~/.config/gh \
    # tmux \
    && git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm \
    && ~/.config/tmux/plugins/tpm/bin/install_plugins \
    # ranger \
    && git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons

# Setup symlink to host home directory to reduce bind mount
# This also enables replacing those links with actual files when symlink is inappriate
RUN rm -rf ~/toybox \
    && ln -s ~/hosthome/.ssh ~/.ssh \
    && ln -s ~/hosthome/.docker/config.json ~/.docker/config.json \
    && ln -s ~/workspace/personal.github.com/Toraja/toybox ~/toybox

CMD ["tail", "-f", "/dev/null"]