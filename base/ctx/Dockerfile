# Simply assigning default value in ARG instruction does not work, maybe because an environment variable
# with the same name is defined in docker-compose file...  So use variable substitution instead.
ARG BASE_IMAGE_TAG
FROM ubuntu:${BASE_IMAGE_TAG:-rolling}

# `unminimize` is required to use `man`
RUN yes | unminimize
# Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.
# Set up to install docker & docker-compose
ARG CPU_ARCH
ARG DOCKER_GID
RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    apt-transport-https ca-certificates curl gnupg lsb-release \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch="${CPU_ARCH}" signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install --no-install-recommends --yes \
        docker-ce docker-ce-cli containerd.io \
        python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && pip install docker-compose \
    # Specify GID for docker as it differs depending on the environment (Docker Desktop etc.) \
    && groupmod --gid ${DOCKER_GID} docker

# Must-have basic packages
RUN apt-get update && apt-get install --no-install-recommends --yes \
        software-properties-common \
    && apt-add-repository ppa:fish-shell/release-3 \
    && add-apt-repository --yes ppa:neovim-ppa/stable \
    && apt-get update && apt-get install --no-install-recommends --yes \
        sudo less man-db locales tree openssh-client \
        git make xclip net-tools netcat fish tmux neovim \
    && rm -rf /var/lib/apt/lists/* \
    # Without this, `man` complains that $LC_* is not set \
    && locale-gen en_US.UTF-8

ARG UID
ARG USER
RUN useradd --create-home --uid ${UID} --groups docker --shell /usr/bin/fish ${USER} \
    && echo "%"${USER}" ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}

# Other nice-to-have tools
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update && apt-get install --no-install-recommends --yes \
        # file required by ranger \
        keychain fzf bat fd-find ripgrep file ranger kubectl \
    && rm -rf /var/lib/apt/lists/* \
    # Rename binaries, which are named differently from other distro, by creating symlink \
    && ln -n $(which batcat) $(dirname $(which batcat))/bat \
    && ln -n $(which fdfind) $(dirname $(which fdfind))/fd \
    && pip install httpie glances \
    && curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | DIR=/usr/local/bin bash \
    && curl -fsSL https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# vim plugin related
RUN apt-get update && apt-get install --no-install-recommends --yes \
        # vim: universal-ctags is required by TagBar, unzip is required by deno \
        universal-ctags unzip \
    && rm -rf /var/lib/apt/lists/* \
    # pynvim is required by deoplote.nvim \
    && pip install pynvim \
    # deno is required by deoppet \
    && curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=/usr/local/ sh

USER ${USER}
WORKDIR /home/${USER}

# --- toybox independent operation ---
RUN \
    # Create directory for volume so that owner will be the ${USER} \
    mkdir -p ~/.cache ~/.local/share ~/.tmux/resurrect \
    # fish (curl complains SSL error under certain environment (VPN etc). Skip installing fisher in such case.) \
    && fish -c 'curl -fsSLO https://git.io/fisher; and source fisher && fisher install \
    jorgebucaran/fisher \
    decors/fish-colored-man \
    laughedelic/fish_logo \
    markcial/upto \
    joehillen/to-fish \
    evanlucas/fish-kubectl-completions \
    && rm fisher; \
    or mkdir -p ~/.config/fish/completions ~/.config/fish/conf.d' \
    && ln -s ~/toybox/fish/functions ~/.config/fish/myfuncs \
    # git \
    && ln -s ~/toybox/git/.gitignore_global ~/.gitignore_global \
    # tmux \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
    # k3d \
    && k3d completion fish > ~/.config/fish/completions/k3d.fish
COPY --chown=${USER}:${USER} ./home ./

# --- toybox dependent operations ---
# (Things that would fail without toybox)
RUN git clone https://github.com/Toraja/toybox.git \
    # fish \
    && ln -s ~/toybox/fish/conf.d/* ~/.config/fish/conf.d/ \
    # tmux \
    && ~/.tmux/plugins/tpm/bin/install_plugins

# Setup symlink to host home directory to reduce bind mount
# This also enables replacing those links with actual files when symlink is inappriate
# Here cloned toybox directory is moved so that it can be used in case host's toybox is unavailable
RUN mkdir ~/build \
    && mv ~/toybox ~/build/ \
    && ln -s ~/hosthome/.ssh ~/.ssh \
    && ln -s ~/hosthome/.docker ~/.docker \
    && ln -s ~/workspace/toraja/toybox ~/toybox

CMD ["tail", "-f", "/dev/null"]
