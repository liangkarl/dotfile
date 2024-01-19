#!/usr/bin/env bash

# https://github.com/b4b4r07/enhancd
# The ENHANCD_DIR variable is a base directory path. It defaults to ~/.enhancd.
export ENHANCD_DIR="$XDG_CONFIG_HOME/enhancd"
# don't override `cd ..` by default
export ENHANCD_ARG_DOUBLE_DOT='...'

__enhancd_fzf_filter='fzf --height 35% --reverse'

# fzy for alternative usage
__enhancd_fzy_filter="fzy -i"

# config enhanced
export ENHANCD_FILTER="$__enhancd_fzf_filter:$__enhancd_fzy_filter"
