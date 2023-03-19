SHELL = /bin/bash

.DEFAULT_GOAL := help

define printhelp
	@printf '%-30s %s\n' $(1) $(2)
endef

define echored
	echo -e "\e[0;31m$(1)\e[0;0m"
endef

define echocyan
	echo -e "\e[0;36m$(1)\e[0;0m"
endef

export PATH := ${HOME}/.local/bin:${PATH} 

.PHONY: help
help:
	$(call printhelp, Target, Description)
	$(call printhelp, ----------, ---------------)
	$(call printhelp, 'bashrc', 'Setup bashrc')
	$(call printhelp, 'fish', 'Install fish shell')
	$(call printhelp, 'docker', 'Install docker and docker-compose')

# Things that required to perform other targets
.PHONY: prerequisite
prerequisite:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes python3-pip
	pip install ansible
	ansible-playbook --ask-become-pass playbooks/prerequisite.yml

.PHONY: bashrc
bashrc:
	grep -q '# Added by host setup makefile' ~/.bashrc || cat ./bashrc >> ~/.bashrc

github_repo_subpath := 'personal.github.com/Toraja'
github_host_user := 'personal.github.com:Toraja'
toybox_repo_url := 'git@${github_host_user}/toybox.git'
cde_repo_url := 'git@${github_host_user}/cde.git'

.PHONY: repositories
repositories:
	./github-latest-release-installer.sh x-motemen ghq ghq_linux_amd64.zip /tmp/ghq_linux_amd64.zip \
		&& unzip /tmp/ghq_linux_amd64.zip -d /tmp/ \
		&& mkdir -p ~/.local/bin/ \
		&& mv /tmp/ghq_linux_amd64/ghq ~/.local/bin/ \
		&& rm -rdf /tmp/ghq_linux_amd64*
	git clone ${toybox_repo_url} ~/toybox
	cat ./gitconfig > ~/.gitconfig
	ghq_root=$$(~/.local/bin/ghq root) \
		&& mkdir -p $${ghq_root}/${github_repo_subpath} \
		&& mv ~/toybox $${ghq_root}/${github_repo_subpath} \
		&& ln -s $${ghq_root}/${github_repo_subpath}/toybox ~/toybox \
		&& mv ~/cde $${ghq_root}/${github_repo_subpath} \
		&& ln -s $${ghq_root}/${github_repo_subpath}/cde ~/cde
	mkdir -p ~/.config/gh

.PHONY: fish
fish:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes software-properties-common
	sudo -E apt-add-repository --yes ppa:fish-shell/release-3
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes fish
	sudo usermod --shell $$(which fish) $$USER || $(call echored,failed to change shell to fish)
	@# fish -i -c 'exit' <- this does not work
	grep -q '# Added by host setup makefile' ~/.config/fish/config.fish &> /dev/null || mkdir -p ~/.config/fish/ && cat ./config.fish >> ~/.config/fish/config.fish
	mkdir -p ~/.config/fish/conf.d/ && ln -s ~/toybox/fish/conf.d/* ~/.config/fish/conf.d/
	ln -s ~/toybox/fish/functions ~/.config/fish/myfuncs

.PHONY: vim
vim:
	./github-latest-release-installer.sh neovim neovim nvim-linux64.deb /tmp/xxx/nvim-linux64.deb && \
		sudo apt install /tmp/xxx/nvim-linux64.deb && \
		rm -rdf /tmp/xxx
	mkdir -p ~/.config/nvim
	test -f ~/.config/nvim/init.vim || echo 'source ~/toybox/nvim/init.vim' > ~/.config/nvim/init.vim
	test -f ~/.config/nvim/ginit.vim || echo 'source ~/toybox/nvim/ginit.vim' > ~/.config/nvim/ginit.vim
	@# If DIPLAY is set, pip get stuck due to python keyring thingy
	# DISPLAY= sudo -E pip install pynvim
	# Place fzf here as telescope.nvim requires it
	./github-latest-release-installer.sh -t junegunn fzf 'fzf-.*-linux_amd64.tar.gz' ~/.local/bin/

.PHONY: tmux
tmux:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes tmux
	git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
	mkdir -p ~/.config/tmux/ && echo 'source ~/toybox/tmux/tmux.conf' > ~/.config/tmux/tmux.conf
	~/.config/tmux/plugins/tpm/bin/install_plugins

.PHONY: docker
docker: docker-clean docker-add-repository docker-install-engine docker-setup

.PHONY: docker-clean
docker-clean:
	@# docker-engine does not exist as package
	sudo -E apt-get remove docker docker.io containerd runc

.PHONY: docker-add-repository
docker-add-repository:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes apt-transport-https ca-certificates curl gnupg lsb-release
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo -E gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	@# check CPU architecure and exit if it does not match
	@if [ $$(uname -m) != 'x86_64' ]; then echo the CPU architecure is not supported; exit 1; fi
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		$$(lsb_release -cs) stable" | sudo -E tee /etc/apt/sources.list.d/docker.list > /dev/null

.PHONY: docker-install-engine
docker-install-engine: # prerequisites commented out for reusability -- docker-clean docker-add-repository
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes docker-ce docker-ce-cli containerd.io docker-compose-plugin
	./github-latest-release-installer.sh -x docker buildx 'buildx-v.*.linux-amd64'  ~/.docker/cli-plugins/docker-buildx

.PHONY: docker-setup
docker-setup:
	sudo -E usermod -aG docker $$(whoami)
	mkdir -p ~/.docker && cat ~/toybox/docker/config.json > ~/.docker/config.json

.PHONY: docker-wsl
docker-wsl:
	@# This is needed for Ubuntu 22.04
	@# Source:
	@# - https://dev.to/felipecrs/simply-run-docker-on-wsl2-3o8
	@# - https://medium.com/twodigits/install-docker-on-wsl-2-with-vpn-support-to-replace-docker-for-windows-45b8e200e171
	sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
	sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

export TASKRC := ${HOME}/.config/taskwarrior/taskrc
.PHONY: taskwarrior
taskwarrior:
	ansible-playbook --ask-become-pass playbooks/taskwarrior.yml

.PHONY: testenv
testenv:
	export UID && docker compose run --rm test

.PHONY: testenv-build
testenv-build:
	export UID && docker compose build test

.PHONY: review-test-base
review-test-base:
	docker pull ubuntu:latest
