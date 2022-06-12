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
        python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    # Specify GID for docker as it differs depending on the environment (Docker Desktop etc.) \
    && groupmod --gid ${DOCKER_GID} docker

# Must-have basic packages
RUN apt-get update && apt-get install --no-install-recommends --yes \
        software-properties-common \
    # && apt-add-repository ppa:fish-shell/release-3 \
    && apt-get update && apt-get install --no-install-recommends --yes \
        sudo less man-db locales tree openssh-client unzip \
        git git-lfs make xclip net-tools netcat fish tmux \
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
        keychain jq ripgrep file ranger kubectl \
        # these required by asdf \
        dirmngr gpg curl gawk \
    && rm -rf /var/lib/apt/lists/* \
    # Rename binaries, which are named differently from other distro, by creating symlink \
    && pip install httpie glances ansible \
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

# --- toybox independent operation ---
RUN \
    # Create directory for volume so that owner will be the ${USER} \
    mkdir -p ~/.cache ~/.local/share \
    # fish (curl complains SSL error under certain environment (VPN etc). Skip installing fisher in such case.) \
    && fish -c 'curl -fsSLO https://git.io/fisher; and source fisher && fisher install \
    jorgebucaran/fisher \
    decors/fish-colored-man \
    decors/fish-ghq \
    laughedelic/fish_logo \
    markcial/upto \
    joehillen/to-fish \
    evanlucas/fish-kubectl-completions \
    edc/bass \
    && rm fisher; \
    or mkdir -p ~/.config/fish/completions ~/.config/fish/conf.d' \
    # change keybind of fish-ghq \
    && sed -i 's/\\cg/\\eo/g' ~/.config/fish/conf.d/ghq_key_bindings.fish \
    && ln -s ~/toybox/fish/functions ~/.config/fish/myfuncs \
    # git \
    && ln -s ~/toybox/git/gitignore_global ~/.gitignore_global \
    # tmux \
    && git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm \
    # docker compose \
    && github_latest_release_installer.sh -x docker compose docker-compose-linux-x86_64 ~/.docker/cli-plugins/docker-compose

ARG ASDF_VERSION
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION} \
    && ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions/ \
    # create tool-versions file under .asdf so that it is included in volume as well \
    && ln -s ~/.asdf/tool-versions ~/.tool-versions \
    && bash -c '. ~/.asdf/asdf.sh \
    && asdf-global-installer.sh \
        direnv \
        neovim \
        grpcurl \
        ghq \
        fd \
        k3d \
        k9s \
        fzf \
        cheat \
        helm \
        helmfile \
    && k3d completion fish > ~/.config/fish/completions/k3d.fish \
    && k9s completion fish > ~/.config/fish/completions/k9s.fish \
    && eval $(asdf where fzf)/install --all' \
    && git clone --depth 1 https://github.com/cheat/cheatsheets.git ~/.config/cheat/cheatsheets/community \
    && ln -s ~/toybox/cheat/conf.yml ~/.config/cheat/conf.yml \
    && ln -s ~/toybox/cheat/cheatsheets ~/.config/cheat/cheatsheets/personal \
    && curl -fsSL -o ~/.config/fish/completions/cheat.fish https://raw.githubusercontent.com/cheat/cheat/master/scripts/cheat.fish
    # tmux is installed via apt because it requireds C compiler and asdf does not resolve the dependency

ENV PATH="/home/${USER}/.krew/bin:$PATH"
RUN krew-installer.sh \
    &&  kubectl krew install tree tail ns

# --- toybox dependent operations ---
# (Things that would fail without toybox)
RUN git clone https://github.com/Toraja/toybox.git \
    # fish \
    && ln -s ~/toybox/fish/conf.d/* ~/.config/fish/conf.d/ \
    # git \
    && ln -s ~/toybox/git/bin/bash/* ~/.local/bin/ \
    && ln -s ~/toybox/git/bin/fish/* ~/.local/bin/ \
    # tmux \
    && ~/.config/tmux/plugins/tpm/bin/install_plugins

# Setup symlink to host home directory to reduce bind mount
# This also enables replacing those links with actual files when symlink is inappriate
# Here cloned toybox directory is moved so that it can be used in case host's toybox is unavailable
RUN mkdir ~/build \
    && mv ~/toybox ~/build/ \
    && ln -s ~/hosthome/.ssh ~/.ssh \
    && ln -s ~/hosthome/.docker/config.json ~/.docker/config.json \
    && ln -s ~/workspace/github.com/Toraja/toybox ~/toybox

CMD ["tail", "-f", "/dev/null"]
