#!/usr/bin/env bash

# https://github.com/b4b4r07/enhancd
# The STARSHIP_CONFIG variable is a base directory path. It defaults to ~/.enhancd.

__starship_bootstrap() {
    export STARSHIP_CONFIG=$(dirname ${BASH_SOURCE[0]})/starship.toml
    eval "$(starship init bash)"
}

oneshot __starship_bootstrap
