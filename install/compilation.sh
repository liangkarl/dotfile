#! /usr/bin/env bash

lib.load devel

list=(curl device-tree-compiler libncurses-dev python3-distutils)
tmp=/tmp/install.log
found_err=n

# APT
if cmd.has apt; then
	for c in ${list[@]}; do
		if sudo apt install -y $c; then
			sys.alter_cmd $c $(which $c)
			msg.info "==== Install $c completed ===="
		else
			found_err=y
		fi
	done
fi | tee $tmp

if [[ "$found_err" == y ]]; then
	msg.err "Error found!"
	msg.err "Please reference log: $tmp"
else
	rm $tmp
fi
