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

.PHONY: git
git:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes git unzip
	curl --output ghq.zip -fsSL https://github.com/x-motemen/ghq/releases/download/v1.2.1/ghq_linux_amd64.zip
	unzip ghq.zip && mkdir -p ~/.local/bin && mv ghq_linux_amd64/ghq ~/.local/bin && rm -rdf ghq.zip ghq_linux_amd64
	ghq get https://github.com/Toraja/toybox.git
	cat ./gitconfig > ~/.gitconfig
	echo "Now, move ghq root directory to the location specified in $$(ghq list --full-path --exact Toraja/toybox)/git/gitconfig, and create symlink to toybox"

.PHONY: fish
fish:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes software-properties-common
	sudo -E apt-add-repository --yes ppa:fish-shell/release-3
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes fish
	sudo usermod --shell $$(which fish) $$USER || echo "failed to change shell to fish :("
	@# fish -i -c 'exit' <- this does not work
	grep -q '# Added by host setup makefile' ~/.config/fish/config.fish &> /dev/null || mkdir -p ~/.config/fish/ && cat ./config.fish >> ~/.config/fish/config.fish
	mkdir -p ~/.config/fish/conf.d/ && ln -s ~/toybox/fish/conf.d/* ~/.config/fish/conf.d/
	ln -s ~/toybox/fish/functions ~/.config/fish/myfuncs

.PHONY: vim
vim:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes software-properties-common
	sudo -E add-apt-repository --yes ppa:neovim-ppa/stable
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes neovim
	mkdir -p ~/.vim/swap ~/.config/nvim
	test -f ~/.config/nvim/init.vim || echo 'source ~/toybox/nvim/init.vim' > ~/.config/nvim/init.vim
	test -f ~/.config/nvim/ginit.vim || echo 'source ~/toybox/nvim/ginit.vim' > ~/.config/nvim/ginit.vim
	@# If DIPLAY is set, pip get stuck due to python keyring thingy
	# DISPLAY= sudo -E pip install pynvim
	git clone https://github.com/junegunn/vim-plug.git ~/.vim/bundle/vim-plug
	nvim --headless -c PlugInstall -c qall

.PHONY: tmux
tmux:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes tmux
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	echo 'source ~/toybox/tmux/tmux.conf' > ~/.tmux.conf
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
	mkdir -p ~/.docker && cat ~/toybox/docker/config.json > ~/.docker/config.json

.PHONY: taskwarrior
taskwarrior:
	sudo -E apt-get update
	sudo -E apt-get install --no-install-recommends --yes cmake gcc g++ uuid-dev
	git clone --recursive -b stable https://github.com/GothenburgBitFactory/taskwarrior.git
	cd taskwarrior && cmake -DCMAKE_BUILD_TYPE=release -DENABLE_SYNC=OFF . && make && sudo make install
	cd .. && rm -rf taskwarrior.tar.gz taskwarrior
	curl -fsSL --output taskwarrior-tui.tar.gz https://github.com/kdheepak/taskwarrior-tui/releases/download/v0.19.1/taskwarrior-tui-x86_64-unknown-linux-gnu.tar.gz
	mkdir -p ~/.local/bin && && tar -xzf taskwarrior-tui.tar.gz --directory=$$HOME/.local/bin && rm taskwarrior-tui.tar.gz
	test -n "${TASKRC}" && mkdir -p $$(dirname ${TASKRC}) && ln -s ~/toybox/taskwarrior/taskrc ${TASKRC} || echo "Create symlink to taskrc manually"

.PHONY: misc
misc:
	sudo -E apt-get install --no-install-recommends --yes xclip
