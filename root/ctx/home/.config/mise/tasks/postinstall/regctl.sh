#!/bin/bash

set -e

mise exec regctl --command "regctl completion fish > ~/.config/fish/completions/regctl.fish"
