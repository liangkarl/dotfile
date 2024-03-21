#!/usr/bin/env bash

# https://github.com/b4b4r07/enhancd
# The ENHANCD_DIR variable is a base directory path. It defaults to ~/.enhancd.

__enhancd_bootstrap() {
    local fzy_filter fzf_filter

    fzf_filter='fzf --height 35% --reverse'
    fzy_filter="fzy -i"
    export ENHANCD_FILTER="$fzf_filter:$fzy_filter"

    export ENHANCD_ENABLE_SINGLE_DOT=false   # Disable sub directories search
    export ENHANCD_ENABLE_HOME=false         # WA for disabling `cd `
    export ENHANCD_ARG_DOUBLE_DOT='...'      # List parent directories
    export ENHANCD_ARG_HYPHEN='--'           # List 10 latest directories
    export ENHANCD_ARG_HOME='='              # List change
    export ENHANCD_DIR="$XDG_CONFIG_HOME/enhancd"
}

__enhancd_bootstrap

