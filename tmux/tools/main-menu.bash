#!/usr/bin/env bash

# basic information
session="$(tmux display-message -p '#S')"
window="$(tmux display-message -p '#W')"
client="$(tmux display-message -p '#{client_name}')"

cat <<-EOF
# TODO:
# [x] show tool menu
# [x] show plugin menu
# [x] show session menu
# [x] show window menu
# [x] show pane menu
EOF
