#!/bin/bash
#
# Create links
#
set -x

PWD=`pwd`
SRC=(
"$PWD/environment/bin"
"$PWD/environment/vim/vimrc"
"$PWD/environment/android"
"/media/karl/ext4/Projects"
"/media/karl/ntfs/MEGA"
)

GOAL=(
"$HOME/bin"
"$HOME/.vimrc"
"$HOME/.android"
"$HOME/Projects"
"$HOME/MEGA"
)

echo ". $PWD/tools/env.cfg" >> $HOME/.profile

i=0
while [ true ]; do
	if [ -z ${SRC[$i]} ]; then
		break;
	fi
	if [ -e ${GOAL[$i]} ]; then
		mv ${GOAL[$i]} ${GOAL[$i]}.bak
	fi
	cp ${SRC[$i]} ${GOAL[$i]}
	i=$((i+1))
done

set +x
