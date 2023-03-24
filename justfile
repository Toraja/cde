set shell := ['/usr/bin/bash', '-c']
set dotenv-load

compose_cmd := 'docker compose --file compose.yml'

export USER_ID := `id -u`
export USER_NAME := `whoami`
export GROUD_ID := `id -g`
export GROUP_NAME := `groups | cut -d ' ' -f1`
export DOCKER_GROUP_ID := `getent group docker | cut -d: -f3`

default:
	@just --list --unsorted

[private]
@echored args:
	echo -e "\e[0;31m{{args}}\e[0;0m"

[private]
@docker_service:
	helpers/start-docker-service.sh

[private]
@validate_cde cde:
	if ! test -d {{cde}}; then \
		just echored 'Invalid cde: {{cde}}'; \
		exit 1; \
	fi

# Build specified targets.
build +target: docker_service
	docker buildx bake {{target}}

config:
	{{compose_cmd}} config --no-interpolate

compose cde +args: (validate_cde cde)
	@# Specify COMPOSE_PROJECT_NAME (which is the service name by default) to avoid the collision of container name and volume name between CDEs
	PRIMARY_CDE={{cde}} \
	COMPOSE_PROJECT_NAME={{ replace_regex(cde, '.*/', '') }} \
	CDE_HOSTNAME={{ 'cde.' + replace_regex(cde, '.*/', '') }} \
	{{compose_cmd}} {{args}}

up cde: (compose cde 'up --no-recreate --no-build --pull never')

start cde: (compose cde 'up --detach --no-recreate --no-build --pull never')

enter cde: (start cde) (compose cde 'exec cde fish')

stop cde: (compose cde 'stop')

down cde: (compose cde 'down')

destroy cde: (compose cde 'down -v')
