# Simply assigning default value in ARG instruction does not work, maybe because an environment variable
# with the same name is defined in docker-compose file...  So use variable substitution instead.
ARG BASE_IMAGE_TAG
FROM ubuntu:${BASE_IMAGE_TAG:-rolling}

# `unminimize` is required to use `man`
RUN yes | unminimize
# Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.
# Set up to install docker and add PPA
ARG CPU_ARCH
RUN apt-get update && apt-get upgrade --no-install-recommends --yes && apt-get install --no-install-recommends --yes \
    apt-transport-https ca-certificates curl gnupg lsb-release \
    software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch="${CPU_ARCH}" signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-add-repository ppa:fish-shell/release-3 \
    && curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
    && add-apt-repository --yes ppa:neovim-ppa/stable
# Install docker and other packages
# ctags required by Tagbar vim plugin
# file required by ranger
RUN apt-get update && apt-get install --no-install-recommends --yes \
    sudo less man-db locales tree openssh-client fish net-tools \
    docker-ce docker-ce-cli containerd.io python3-pip kubectl \
    git neovim tmux keychain fzf xclip make universal-ctags bat fd-find ripgrep file ranger \
    && rm -rf /var/lib/apt/lists/* \
    # Rename binaries, which are named differently from other distro, by creating symlink \
    && ln -n $(which batcat) $(dirname $(which batcat))/bat \
    && ln -n $(which fdfind) $(dirname $(which fdfind))/fd \
    # Without this, `man` complains that $LC_* is not set \
    && locale-gen en_US.UTF-8

# pynvim required by deoplote.nvim
RUN pip install docker-compose httpie glances pynvim

RUN curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash \
    && curl -fsSL https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash \
    && curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=/usr/local/ sh

# Docker Desktop uses different GID for docker
ARG DOCKER_GID
RUN groupmod --gid ${DOCKER_GID} docker

ARG UID
ARG USER
RUN useradd --create-home --uid ${UID} --groups docker --shell /usr/bin/fish ${USER} \
    && echo "%"${USER}" ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}
USER ${USER}

WORKDIR ${HOME}

# --- toybox independent operation ---
RUN \
    # fish (curl complains SSL error under certain environment (VPN etc). Skip installing fisher in such case.) \
    fish -c 'curl -fsSLO https://git.io/fisher; and source fisher && fisher install \
    jorgebucaran/fisher \
    decors/fish-colored-man \
    laughedelic/fish_logo \
    markcial/upto \
    joehillen/to-fish \
    evanlucas/fish-kubectl-completions \
    && rm fisher; \
    or mkdir -p ~/.config/fish/completions ~/.config/fish/conf.d' \
    && ln -s ~/toybox/fish/functions ~/.config/fish/myfuncs \
    && k3d completion fish > ~/.config/fish/completions/k3d.fish \
    # tmux \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
    # Create directory for volume so that owner will be the ${USER} \
    && mkdir -p ~/.cache ~/.local/share ~/.tmux/resurrect
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
    && ln -s ~/workspace/toraja/toybox ~/toybox \
    # Prevent Deoplete error that asks you to run UpdateRemotePlugins \
    && ln -s ~/hosthome/.local/share/nvim ~/.local/share/nvim

CMD ["tail", "-f", "/dev/null"]
