#!/bin/bash

VERIFY='username=ubuntu,password=12cdCD'
NETFOLDERS=(
'//10.0.1.110/Hudson/ShareData/CSDataRelease'
'//10.0.0.166/Public_Folder/CQ/SPCSS/'
)
FOLDERS=(
'Hudson'
'CQ'
)

init_folder() {
	i=0
	while [ ! -z ${NETFOLDERS[$i]} ]; do
		if [ ! -e ${FOLDERS[$i]} ]; then
			mkdir ${FOLDERS[$i]}
		fi
		sudo mount -o $VERIFY ${NETFOLDERS[$i]} ${FOLDERS[$i]}
		i=$((i+1))
	done
}

init_folder
