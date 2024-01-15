# Simply assigning default value in ARG instruction does not work, maybe because an environment variable
# with the same name is defined in compose file...  So use variable substitution instead.
ARG BASE_IMAGE_TAG
FROM ubuntu:${BASE_IMAGE_TAG:-rolling}

# `unminimize` is required to use `man`
RUN yes | unminimize

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.
# Set up to install docker
ARG DOCKER_GROUP_ID
RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    apt-transport-https ca-certificates curl gnupg lsb-release \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install --no-install-recommends --yes \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/* \
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
    && rm -rf /var/lib/apt/lists/* \
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
        keychain jq ripgrep skopeo \
        # these required by asdf \
        dirmngr gpg curl gawk \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | DIR=/usr/local/bin bash

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

COPY --chown=${USER_NAME}:${USER_NAME} ./home ./
ENV PATH="/home/${USER_NAME}/.local/bin:${PATH}"

COPY --chown=${USER_NAME}:${USER_NAME} ./helpers/install-fish-plugins.fish /home/${USER_NAME}/.local/bin/
RUN mkdir -p ~/tmp \
    && for p in httpie glances ansible-base yamllint; do pipx install $p; done \
    && github-latest-release-installer.sh -T yamlfmt google yamlfmt 'yamlfmt_.*_Linux_x86_64.tar.gz' ~/.local/bin/ \
    && bash <(curl -s https://raw.githubusercontent.com/kamiyaa/joshuto/master/utils/install.sh)

COPY --chown=${USER_NAME}:${USER_NAME} ./helpers/install-asdf-plugins.sh /home/${USER_NAME}/.local/bin/
RUN asdf_version=$(curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq -r '.tag_name') \
    && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${asdf_version} \
    && mkdir -p ~/.config/fish/completions/ \
    && ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions/ \
    && install-asdf-plugins.sh

COPY --from=catalog lang/lua /tmp/catalog/lua
RUN for installer in /tmp/catalog/*/install.sh; do $installer; done && \
    sudo rm -rf /tmp/catalog

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
    # pipx \
    && register-python-argcomplete --shell fish pipx > ~/.config/fish/completions/pipx.fish \
    # lazygit \
    && mkdir -p ~/.config/lazygit/ && ln -s ~/toybox/lazygit/config.yml ~/.config/lazygit/ \
    # tmux \
    && git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm \
    && ~/.config/tmux/plugins/tpm/bin/install_plugins \
    # joshuto \
    && ln -s ~/toybox/joshuto ~/.config/ \
    && curl -fsSL https://raw.githubusercontent.com/kamiyaa/joshuto/main/config/preview_file.sh > ~/.local/bin/joshuto_preview_file.sh \
    && chmod 755 ~/.local/bin/joshuto_preview_file.sh \
    && joshuto completions fish > ~/.config/fish/completions/joshuto.fish \
    # yamlfmt & yamllint \
    && ln -s ~/toybox/{yamlfmt,yamllint} ~/.config/

# Setup symlink to host home directory to reduce bind mount
# This also enables replacing those links with actual files when symlink is inappriate
RUN rm -rf ~/toybox \
    && ln -s ~/hosthome/.ssh ~/.ssh \
    && mkdir --parents ~/.docker && ln -s ~/hosthome/.docker/config.json ~/.docker/config.json \
    && ln -s ~/workspace/personal.github.com/Toraja/toybox ~/toybox

# Create directories for volume mount destination so that owner:group of those directories are not root.
RUN mkdir --parents ~/.cache ~/.local/{share,state}

CMD ["tail", "-f", "/dev/null"]
