#!/usr/bin/env bash

# https://github.com/b4b4r07/enhancd
# The ENHANCD_DIR variable is a base directory path. It defaults to ~/.enhancd.
export ENHANCD_DIR="$XDG_CONFIG_HOME/enhancd"
# don't override `cd ..` by default
export ENHANCD_ARG_DOUBLE_DOT='...'
# config enhanced
export ENHANCD_FILTER="fzf --preview 'ls -v --group-directories-first -N --color=auto -l --time-style=long-iso {}' --preview-window right,50% --height 35% --reverse --ansi"
