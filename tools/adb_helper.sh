#!/bin/bash

__ADB=$(which adb)
__ADB=${__ADB:-./adb.exe}

__adb_animate_star() {
	local COUNT IMAGE
	COUNT="$1"
	IMAGE=$((COUNT % 4))
	case $IMAGE in
		1) echo -en '\';;
		2) echo -en '|';;
		3) echo -en '/';;
		0 | *) echo -en '-'
	esac
}

__adb_animate_cmd() {
	local char
	chars="/-\|"

	while :; do
		for (( i=0; i<${#chars}; i++ )); do
			sleep 0.5
			echo -en "${chars:$i:1}" "\r"
		done
	done
}

adb_shell() {
	# echo "cmd: $CMD"
	$__ADB shell "$@"
	echo "adb_shell: ok"
}

adb_root() {
	local COUNT INTV BREAK STR
	COUNT=0
	INTV=0.3
	BREAK='false'
	while [ $BREAK == 'false' ]; do
		$__ADB root &> /dev/null && {
			echo " adb_root: ok"
			break;
		}
		echo -en "\rkeep trying to get root permission... $(__adb_animate_star $COUNT)"
		COUNT=$((COUNT + 1))
		sleep $INTV
	done
}

adb_loop_shell_cmd() {
	local INTV
	INTV=0.1
	echo "sleep: $SLEEP sec"
	while [ true ]; do
		sleep $INTV
		# <C-c> to stop
		adb_shell "$@"
	done
}

adb_kmsg_grepper() {
	local KEYWORD KMSG
	KMSG='/proc/kmsg'
	KEYWORD="$@"
	adb_root
	adb_shell "cat $KMSG | grep $KEYWORD"
}

adb_ints_grepper() {
	local INT KEYWORD LOOP_READ
	KEYWORD="$@"
	INT='/proc/interrupts'
	LOOP_READ="while :; do cat $INT | grep $KEYWORD | tr '\n' '\r'; done"
	adb_shell "head -1 $INT; $LOOP_READ"
}
