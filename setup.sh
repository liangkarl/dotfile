#!/bin/bash
#
# Create links
#
set -x

PWD=`pwd`
ENV='env'
ETC='etc'
TOOLS='tools'

SRC=(
"$PWD/$ENV/bin"
"$PWD/$ENV/vim/vimrc"
"$PWD/$ENV/android"
)

GOAL=(
"$HOME/bin"
"$HOME/.vimrc"
"$HOME/.android"
)

SRC_AND_DEST=(
"$PWD/$ENV/bin:$HOME/bin"
"$PWD/$ENV/vim/vimrc:$HOME/.vimrc"
"$PWD/$ENV/android:$HOME/.android"
)

echo ". $PWD/$TOOLS/env.cfg" >> $HOME/.profile

i=0
for i in $(0:${#SRC_AND_DEST[@]}) do
        [ -z ${SRC[$i]} ] && continue;
	[ -e ${GOAL[$i]} ] && mv ${GOAL[$i]} ${GOAL[$i]}.bak
	cp ${SRC[$i]} ${GOAL[$i]}
done

set +x
