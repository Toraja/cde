SHELL = /bin/bash

# Specify COMPOSE_PROJECT_NAME to avoid the collision of container name and volume name between CDEs
base_cmd = COMPOSE_PROJECT_NAME=$(c) docker-compose --file docker-compose.yml --file ./$(c)/docker-compose.yml

define validate_arg
	@if [[ -z "$(c)" ]]; then echo 'Specify CDE as in `c=<cde>`'; exit 1; fi
endef

.DEFAULT_GOAL := dummy

.PHONY: dummy
dummy:
	@echo Select a target.

.PHONY: docker_service
docker_service:
	@./start-docker-service.sh

.PHONY: validate_arg
validate_arg:
	$(call validate_arg)

.PHONY: custom
custom: validate_arg
	$(base_cmd) $(args)

.PHONY: config
config: validate_arg docker_service
	$(base_cmd) config

.PHONY: build
build: validate_arg docker_service
	$(base_cmd) build

.PHONY: up
up: validate_arg docker_service
	$(base_cmd) up --no-recreate

.PHONY: start
start: validate_arg docker_service
	$(base_cmd) up -d --no-recreate

.PHONY: enter
enter: start
	$(base_cmd) exec cde fish

.PHONY: stop
stop: validate_arg docker_service
	$(base_cmd) stop

.PHONY: down
down: validate_arg docker_service
	$(base_cmd) down

.PHONY: destroy
destroy: validate_arg docker_service
	$(base_cmd) down -v
