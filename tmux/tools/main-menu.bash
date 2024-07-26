#!/usr/bin/env bash

# basic information
session="$(tmux display-message -p '#S')"
window="$(tmux display-message -p '#W')"
client="$(tmux display-message -p '#{client_name}')"
pane="$(tmux display-message -p '#{pane_id}')"

# finder='fzf-tmux -p 40%,40% -- --reverse'

lib.add menu

main_menu=("clipboard" "keys" "tools" "plugin" "session" "window" "pane")
session_menu=("new" "kill" "switch" "detach" "rename")
win_menu=("swap" "break" "kill" "switch" "move" "rename" "link")
pane=("swap" "break" "kill" "switch" "join" "layout" "resize")
cb_ans=

if ! type -t fzf; then
    echo "no 'fzf' found!" >&2
    return 1
fi &> /dev/null

update_cb() {
    cb_ans="$2"
}

main() {
    menu.height 15
    menu.opts "${main_menu[@]}"
    menu.add_exit
    menu.run
}

window() {
    menu.height 15
    menu.opts "${win_menu[@]}"
    menu.add_cancel
    menu.add_exit
    menu.run
}

pane() {
    menu.height 15
    menu.opts "${pane_menu[@]}"
    menu.add_cancel
    menu.add_exit
    menu.run
}

session() {
    menu.height 15
    menu.opts "${session_menu[@]}"
    menu.add_cancel
    menu.add_exit
    menu.run
}

menu.backend "fzf-tmux"
menu.callback update_cb
state="main"
while :; do
    eval "$state"
    next="$cb_ans"
    if [[ -z "$next" ]]; then
        echo "no next step" >&2
        exit
    fi
    if [[ "$next" == "exit" ]]; then
        exit
    fi
    if [[ "$next" == "cancel" ]]; then
        next="main"
    fi
    eval "state=$next"
done
