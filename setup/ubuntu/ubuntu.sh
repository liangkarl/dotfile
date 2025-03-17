#! /usr/bin/env bash

lib.load devel

list=(curl vim make gawk sharutils build-essential gcc python2 python3 libncurses-dev openjdk-8-jdk xclip)
tmp=/tmp/install.log
found_err=n

# APT
sudo add-apt-repository -y ppa:mozillateam/ppa
sudo add-apt-repository -y ppa:hluk/copyq
sudo apt update

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
