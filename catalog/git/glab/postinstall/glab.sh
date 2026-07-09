#!/bin/bash

set -e

mise exec glab --command "glab completion --shell fish > ~/.config/fish/completions/glab.fish"
