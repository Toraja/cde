SHELL = /bin/bash

.DEFAULT_GOAL := help

define printhelp
	@printf '%-30s %s\n' $(1) $(2)
endef

.PHONY: help
help:
	$(call printhelp, Target, Description)
	$(call printhelp, ----------, ---------------)
	$(call printhelp, 'bashrc', 'Setup bashrc')
	$(call printhelp, 'fish', 'Install fish shell')
	$(call printhelp, 'docker', 'Install docker and docker-compose')

.PHONY: bashrc
bashrc:
	grep -q '# Added by host setup makefile' ~/.bashrc || cat ./bashrc >> ~/.bashrc

.PHONY: fish
fish:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes software-properties-common
	sudo -E apt-add-repository --yes ppa:fish-shell/release-3
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes fish
	sudo usermod --shell $$(which fish) $$USER || echo "failed to change shell to fish :("
	@# fish -i -c 'exit' <- this does not work
	grep -q '# Added by host setup makefile' ~/.config/fish/config.fish || cat ./config.fish >> ~/.config/fish/config.fish
	mkdir -p ~/.config/fish/conf.d/ && ln -s ~/toybox/fish/conf.d/* ~/.config/fish/conf.d/
	ln -s ~/toybox/fish/functions ~/.config/fish/myfuncs

.PHONY: vim
vim:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes python3-pip neovim
	mkdir -p ~/.vim/swap ~/.config/nvim
	test -f ~/.config/nvim/init.vim || echo 'source ~/toybox/nvim/init.vim' > ~/.config/nvim/init.vim
	test -f ~/.config/nvim/ginit.vim || echo 'source ~/toybox/nvim/ginit.vim' > ~/.config/nvim/ginit.vim
	@# If DIPLAY is set, pip get stuck due to python keyring thingy
	DISPLAY= sudo -E pip install pynvim
	git clone https://github.com/junegunn/vim-plug.git ~/.vim/bundle/vim-plug
	nvim --headless -c PlugInstall -c qall

.PHONY: tmux
tmux:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes tmux
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	echo 'source ~/toybox/tmux/.tmux.conf' > ~/.tmux.conf
	~/.tmux/plugins/tpm/bin/install_plugins

.PHONY: docker
docker: docker-clean docker-add-repository docker-install-engine docker-compose-install docker-setup

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
	sudo -E apt-get install --no-install-recommends --yes docker-ce docker-ce-cli containerd.io

.PHONY: docker-compose-install
docker-compose-install:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes python3-pip
	sudo -E pip install docker-compose

.PHONY: docker-setup
docker-setup:
	sudo -E usermod -aG docker $$(whoami)
	mkdir -p ~/.docker && ln -s ~/toybox/docker/config.json ~/.docker/
	sudo docker volume create --label=prune=false vim-plugin
	sudo docker volume create --label=prune=false gopath

.PHONY: misc
misc:
	@# use `-p` to avoid error in case any of these directory already exists
	mkdir -p ~/workspace
