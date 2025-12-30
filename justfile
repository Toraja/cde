set shell := ['/usr/bin/bash', '-c']
set dotenv-load

compose_cmd := 'docker compose --file compose.yml'

export USER_ID := `id -u`
export USER_NAME := `whoami`
export GROUP_ID := `id -g`
export GROUP_NAME := `groups | cut -d ' ' -f1`
export DOCKER_GROUP_ID := `getent group docker | cut -d: -f3`
export BASE_IMAGE_TAG := `echo ${BASE_IMAGE_TAG:-rolling}`

default:
	@just --list --unsorted

[private]
@echored args:
	echo -e "\e[0;31m{{args}}\e[0;0m"

[private]
@echocyan args:
	echo -e "\e[0;36m{{args}}\e[0;0m"

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
build target *bakeflag: docker_service
	#!/usr/bin/env fish
	set --export BUILDX_BAKE_ENTITLEMENTS_FS 0
	docker pull ubuntu:$BASE_IMAGE_TAG
	docker pull rust:latest
	set target (string replace '/' '_' {{trim_start_match(trim_end_match(target, '/'), 'env/')}})
	set flag --file docker-bake.hcl
	set env_root (string replace --regex '([^/]+/[^/]+/).*' '$1' {{target}})
	test -f $env_root/docker-bake.hcl && set flag $flag --file $env_root/docker-bake.hcl
	docker buildx bake $flag {{bakeflag}} $target

# Parse and print bake file
build-print target: (build target '--print')

root-test-build *bakeflag:
	export BUILDX_BAKE_ENTITLEMENTS_FS=0
	docker buildx bake --file docker-bake.hcl {{bakeflag}} root_test

root-test-enter:
	docker run --interactive --tty --rm --detach --name root_test cde/root-test:latest
	docker exec --interactive --tty root_test bash

root-test-stop:
	docker stop root_test

config:
	{{compose_cmd}} config --no-interpolate

compose cde +args: (validate_cde cde)
	#!/usr/bin/env fish
	# Specify COMPOSE_PROJECT_NAME (which is the service name by default) to avoid the collision of container name and volume name between CDEs
	set cde {{trim_start_match(trim_end_match(cde, '/'), 'env/')}}
	set --query COMPOSE_PROJECT_NAME || set --export COMPOSE_PROJECT_NAME (string replace '/' '_' "$cde")
	PRIMARY_CDE=$cde \
	CDE_HOSTNAME=(string replace '/' '.' "$cde") \
	TZ=(cat /etc/timezone) \
	{{compose_cmd}} {{args}}

up cde: (compose cde 'up --no-recreate --no-build --pull never')

start cde: (compose cde 'up --detach --no-recreate --no-build --pull never')

enter cde: (start cde) (compose cde 'exec cde fish')

stop cde: (compose cde 'stop')

down cde: (compose cde 'down')

destroy cde: (compose cde 'down -v')

new-env bundle project:
	#!/usr/bin/env bash
	new_bundle=false
	test -d env/{{bundle}} || new_bundle=true
	set -euo pipefail
	if $new_bundle; then
		cp --recursive skeleton/bundle/ env/{{bundle}}
		mv env/{{bundle}}/project env/{{bundle}}/{{project}}
	else
		cp --recursive skeleton/bundle/project env/{{bundle}}/{{project}}
	fi
	sed --in-place --expression 's/xxx-bundle/{{bundle}}/g' --expression 's/yyy-project/{{project}}/g' env/{{bundle}}/docker-bake.hcl
	just echocyan "Setup is almost done!"
	just echocyan "Modify 'env/{{bundle}}/{{project}}/ctx/Dockerfile' as you like"
	if $new_bundle; then \
		just echocyan "And if you don't need common setup for your projects, remove 'base' section and change default image of 'PROJECT_BASE_IMAGE' in 'docker-bake.hcl' to 'target:root'"; \
	fi
