SHELL = /bin/bash

-include localise/Makefile

empty :=
comma := ,
space := $(empty) $(empty)
target_cde_list := $(subst $(comma),$(space),$(c))
compose_file_flags := $(foreach cde,$(target_cde_list),--file ./$(cde)/docker-compose.yml)
compose_project_name := $(lastword $(target_cde_list))
# Specify COMPOSE_PROJECT_NAME to avoid the collision of container name and volume name between CDEs
base_cmd = COMPOSE_PROJECT_NAME=$(compose_project_name) docker-compose --file docker-compose.yml $(compose_file_flags)

define validate_arg_cde
	@if [[ -z "$(c)" ]]; then \
		echo 'Specify CDE as in `c=<cde>[,cde2...]`'; \
		exit 1; \
	fi
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
	$(call validate_arg_cde)

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
