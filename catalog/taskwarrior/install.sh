#!/bin/bash

# TODO: fix path
ansible-playbook --extra-vars "inside_container=true" playbooks/taskwarrior.yml
