#!/usr/bin/env bash

# https://github.com/b4b4r07/enhancd
# The ENHANCD_DIR variable is a base directory path. It defaults to ~/.enhancd.
export ENHANCD_DIR="$XDG_CONFIG_HOME/enhancd"
# don't override `cd ..` by default
export ENHANCD_ARG_DOUBLE_DOT='...'

__enhancd_fzf_filter="fzf --preview 'ls -v --group-directories-first -N --color=auto -l --time-style=long-iso {}' --preview-window right,50% --height 35% --reverse --ansi"

# there is a TUI issue for preview height in skim.
__enhancd_skim_filter="sk --preview 'ls -v --group-directories-first -N --color=auto -l --time-style=long-iso {}' --preview-window right,50%  --reverse --ansi"
# config enhanced
export ENHANCD_FILTER="$__enhancd_fzf_filter:$__enhancd_skim_filter"
