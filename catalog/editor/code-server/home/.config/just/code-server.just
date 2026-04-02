config_path := '~/.config/code-server/config.yaml'
file_stem := file_stem(source_file())

default:
	@just --global-justfile --list {{file_stem}} --unsorted

run *flags: pass
	code-server {{flags}}

pass:
	#!/bin/bash
	if [ "$(yq '.password' {{config_path}})" = "null" ]; then
		yq --inplace '.password = "'"$(openssl rand -base64 32 | tr --delete '/+=' | head --bytes 32)"'"' {{config_path}}
		echo "Password added to {{config_path}}"
	fi
	echo Password: $(yq '.password' {{config_path}})

config:
	${VISUAL:-${EDITOR:-vim}} {{config_path}}
