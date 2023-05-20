#!/usr/bin/env bash

#
# Create an float terminal window in tmux
#
# NOTE: This script should be used in tmux keybind
#

# detect current session & window name
session="$(tmux display-message -p '#S')"
window="$(tmux display-message -p '#W')"
d="clear; echo Take it easy. The console is loading; sleep 2; clear"

tmux new-window -n 'debug' ';' \
	send-keys "tmex 'pid$$' 3 '$d; logcat' '$d; kmsg' '$d; uart -l'" ENTER
