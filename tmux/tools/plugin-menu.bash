#!/usr/bin/env bash

dir="${XDG_CONFIG_HOME}/tmux/plugins/tpm/bindings"

# basic information
session="$(tmux display-message -p '#S')"
window="$(tmux display-message -p '#W')"
client="$(tmux display-message -p '#{client_name}')"
pane="$(tmux display-message -p '#{pane_id}')"
finder='fzf-tmux -p 40%,40% -- --reverse'

if ! type -t fzf; then
    echo "no 'fzf' found!" | $finder
    return 1
fi &> /dev/null

menu=(
    "Install-Plugins"
	"Update-Plugins"
	"Clean-Plugins"
	"Cancel"
)
ans=$(echo ${menu[@]} | sed -e 's/ /\n/g' -e 's/-/ /g' | $finder)

case $ans in
	Install*)
		eval ${dir}/install_plugins
		;;
	Update*)
		eval ${dir}/update_plugins
		;;
	Clean*)
		eval ${dir}/clean_plugins
		;;
esac
