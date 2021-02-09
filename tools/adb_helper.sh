#!/bin/bash

__ADB=$(which adb)
__ADB=${__ADB:-./adb.exe}

adb_shell() {
	local CMD
	CMD="$@"
	echo "cmd: $CMD"
	$__ADB shell $CMD
	echo "adb_shell: ok"
}

adb_root() {
	local COUNT CMD INTV
	COUNT=0
	INTV=0.1
	while [ true ]; do
		[ $COUNT -eq 10 ] && echo "disable error output."

		if [ $COUNT -lt 10 ]; then
			$__ADB root
		else
			$__ADB root >&-
		fi
		COUNT=$((COUNT + 1))
		sleep $INTV
	done
	echo "adb_root: ok"
}

adb_loop_shell_cmd() {
	local INTV CMD
	CMD="$@"
	INTV=0.1
	echo "sleep: $SLEEP sec"
	echo "cmd: $CMD"
	echo ""
	while [ true ]; do
		sleep $INTV
		$__ADB shell $CMD
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
	local INT KEYWORD
	KEYWORD="$@"
	INT='/proc/interrupts'
	adb_root
	adb_shell "head -1 $INT; while 0; do cat $INT | grep $KEYWORD; done"
}
