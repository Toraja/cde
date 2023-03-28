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
	if test -f helpers/start-docker-service.sh; then \
		helpers/start-docker-service.sh; \
	else \
		cde/helpers/start-docker-service.sh; \
	fi

[private]
@validate_cde cde:
	if ! test -d {{cde}}; then \
		just echored 'Invalid cde: {{cde}}'; \
		exit 1; \
	fi

# Build specified targets.
build target bakeflag='': docker_service
	#!/usr/bin/env fish
	set target (string replace '/' '_' {{trim_start_match(trim_end_match(target, '/'), 'env/')}})
	set flag --file docker-bake.hcl
	set env_root (string replace --regex '([^/]+/[^/]+/).*' '$1' {{target}})
	test -f $env_root/docker-bake.hcl && set flag $flag --file $env_root/docker-bake.hcl
	docker buildx bake $flag {{bakeflag}} $target

# Parse and print bake file
build-print target: (build target '--print')

config:
	{{compose_cmd}} config --no-interpolate

compose cde +args: (validate_cde cde)
	#!/usr/bin/env fish
	# Specify COMPOSE_PROJECT_NAME (which is the service name by default) to avoid the collision of container name and volume name between CDEs
	set cde {{trim_start_match(trim_end_match(cde, '/'), 'env/')}}
	PRIMARY_CDE=$cde \
	COMPOSE_PROJECT_NAME=(string replace '/' '_' "$cde") \
	CDE_HOSTNAME=(string replace '/' '.' "$cde") \
	{{compose_cmd}} {{args}}

up cde: (compose cde 'up --no-recreate --no-build --pull never')

start cde: (compose cde 'up --detach --no-recreate --no-build --pull never')

enter cde: (start cde) (compose cde 'exec cde fish')

stop cde: (compose cde 'stop')

down cde: (compose cde 'down')

destroy cde: (compose cde 'down -v')
