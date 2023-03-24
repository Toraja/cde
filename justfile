set shell := ['/usr/bin/bash', '-c']
set dotenv-load

export USER_ID := `id -u`
export USER_NAME := `whoami`
export GROUD_ID := `id -g`
export GROUP_NAME := `groups | cut -d ' ' -f1`
export DOCKER_GROUP_ID := `getent group docker | cut -d: -f3`

default:
	@just --list --unsorted


[private]
docker_service:
	@helpers/start-docker-service.sh

# Build specified targets.
build +target: docker_service
	docker buildx bake {{target}}
