SHELL = /bin/bash

-include localise/Makefile

empty :=
comma := ,
space := $(empty) $(empty)
target_cde_list := $(subst $(comma),$(space),$(c))
compose_files := $(foreach cde,$(target_cde_list),$(wildcard ./$(cde)/compose.yml))
compose_file_flags := $(foreach compose,$(compose_files),--file $(compose))
envs := $(foreach cde,$(target_cde_list),$(wildcard ./$(cde)/.env))
primary_cde := $(lastword $(target_cde_list))
compose_project_name := $(or $(pj), $(subst /,_,$(primary_cde)))
image_name := $(or $(pj), $(primary_cde))
host_name := cde.$(subst /,.,$(primary_cde))
# Specify COMPOSE_PROJECT_NAME to avoid the collision of container name and volume name between CDEs
base_cmd = COMPOSE_PROJECT_NAME=$(compose_project_name) PRIMARY_CDE=$(primary_cde) CDE_IMAGE_NAME=$(image_name) CDE_HOSTNAME=$(host_name) \
		   docker compose --file compose.yml $(compose_file_flags)

define validate_arg_cde
	@if [[ -z "$(c)" ]]; then \
		echo 'Specify CDE as in `c=<cde>[,cde2...]`'; \
		exit 1; \
	fi
endef

include .env $(envs)
export

.DEFAULT_GOAL := dummy

.PHONY: dummy
dummy:
	@echo Select a target.

.PHONY: docker_service
docker_service:
	@helpers/start-docker-service.sh

.PHONY: validate_arg
validate_arg:
	$(call validate_arg_cde)

.PHONY: pre_process
pre_process: validate_arg docker_service

.PHONY: custom
custom: pre_process
	$(base_cmd) $(args)

.PHONY: config
config: pre_process
	$(base_cmd) config

.PHONY: build
build: pre_process
	$(base_cmd) build

.PHONY: up
up: pre_process
	$(base_cmd) up --no-recreate

.PHONY: start
start: pre_process
	$(base_cmd) up -d --no-recreate

.PHONY: enter
enter: start
	$(base_cmd) exec cde fish

.PHONY: stop
stop: pre_process
	$(base_cmd) stop

.PHONY: down
down: pre_process
	$(base_cmd) down

.PHONY: destroy
destroy: pre_process
	$(base_cmd) down -v
