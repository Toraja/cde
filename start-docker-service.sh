#!/bin/bash

dist_wsl='wsl'

is_wsl() {
	grep -q -i microsoft /proc/version && return 0 || return 1
}

is_docker_desktop() {
	test -L ~/.docker/contexts && return 0 || return 1
}

get_dist() {
	is_wsl && echo ${dist_wsl} && return
}

is_docker_running() {
	docker ps &>/dev/null && return 0 || return 1
}

start_docker_init_script() {
	sudo service docker start
}

main() {
	is_docker_running
	[[ $? -eq 0 ]] && return 0

	cyan=$(tput setaf 6)
	nc=$(tput sgr 0)
	echo ${cyan}Starting Docker...${nc}

	case $(get_dist) in
		${dist_wsl})
			if is_docker_desktop; then
				if [[ -f /mnt/c/Program\ Files/Docker/Docker/Docker\ Desktop.exe ]]; then
					/mnt/c/Program\ Files/Docker/Docker/Docker\ Desktop.exe &
					echo ${cyan}Docker Desktop has been dispatched.${nc}
					return 0
				else
					echo 'Docker Desktop excutable was not found. Start it manually.'
					exit 1
				fi
			fi

			start_docker_init_script
			;;
		*)
			echo "Unsupported distribution"
			exit 1
	esac
}

main

