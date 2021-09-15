# Simply assigning default value in ARG instruction does not work, maybe because an environment variable
# with the same name is defined in docker-compose file...  So use variable substitution instead.
ARG IMAGE_TAG
FROM ubuntu:${IMAGE_TAG:-rolling}

# `unminimize` is required to use `man`
RUN yes | unminimize
# Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.
# Set up to install docker and add PPA
ARG CPU_ARCH
RUN apt-get update && apt-get upgrade && apt-get install --no-install-recommends --yes \
    apt-transport-https ca-certificates curl gnupg lsb-release \
    software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch="${CPU_ARCH}" signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-add-repository ppa:fish-shell/release-3 \
    && curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
# Install docker and other packages
# ctags required by Tagbar vim plugin
RUN apt-get update && apt-get install --no-install-recommends --yes \
    sudo less man-db locales tree openssh-client fish \
    docker-ce docker-ce-cli containerd.io python3-pip kubectl \
    git neovim tmux keychain fzf xclip make universal-ctags bat fd-find ripgrep \
    && rm -rf /var/lib/apt/lists/* \
    # Rename binaries, which are named differently from other distro, by creating symlink \
    && ln -n $(which batcat) $(dirname $(which batcat))/bat \
    && ln -n $(which fdfind) $(dirname $(which fdfind))/fd \
    # Without this, `man` complains that $LC_* is not set \
    && locale-gen en_US.UTF-8

# pynvim required by deoplote.nvim
RUN pip install docker-compose httpie glances pynvim

RUN curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash \
    && curl -fsSL https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

ARG USER
RUN useradd --create-home --groups docker --shell /usr/bin/fish ${USER} \
    && echo "%"${USER}" ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}
USER ${USER}

WORKDIR /home/${USER}

# --- toybox independent operation ---
RUN \
    # fish \
    fish -c 'curl -sL https://git.io/fisher | source && fisher install \
    jorgebucaran/fisher \
    decors/fish-colored-man \
    laughedelic/fish_logo \
    markcial/upto \
    oh-my-fish/plugin-pj \
    evanlucas/fish-kubectl-completions' \
    && k3d completion fish > ~/.config/fish/completions/k3d.fish \
    # tmux \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
    # vim \
    && mkdir -p .config/nvim .vim/swap \
    && git clone https://github.com/junegunn/vim-plug.git .vim/bundle/vim-plug
COPY --chown=${USER}:${USER} ./gitconfig .gitconfig
COPY --chown=${USER}:${USER} ./config.fish .config/fish/
COPY --chown=${USER}:${USER} ./tmux.conf .tmux.conf

# --- toybox dependent operations ---
RUN git clone https://github.com/Toraja/toybox.git \
    # fish \
    && ln -s ~/toybox/fish/conf.d/* ~/.config/fish/conf.d/ \
    && ln -s ~/toybox/fish/functions ~/.config/fish/myfuncs \
    # tmux \
    && ~/.tmux/plugins/tpm/bin/install_plugins \
    # vim \
    && ln -s ~/toybox/nvim/*.vim ~/.config/nvim/ \
    && ln -s ~/toybox/vim/rtp/* ~/.vim/ \
    && nvim -u ~/.config/nvim/init.vim --headless -c PlugInstall -c qall

# Setup symlink to host home directory to reduce bind mount
# This also enables replacing those links with actual files when symlink is inappriate
# Here cloned toybox directory is moved so that it can be used in case host's toybox is unavailable
RUN mkdir ~/build \
    && mv ~/toybox ~/build/ \
    && ln -s ~/hosthome/.ssh ~/.ssh \
    && ln -s ~/hosthome/.docker ~/.docker \
    && ln -s ~/hosthome/toybox ~/toybox

CMD ["tail", "-f", "/dev/null"]
