#!/usr/bin/env bash

# basic information
session="$(tmux display-message -p '#S')"
window="$(tmux display-message -p '#W')"
client="$(tmux display-message -p '#{client_name}')"

tig || tmux display-message -c ${client} "'tig' report error $?"
