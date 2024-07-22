#!/usr/bin/env bash

# chk_ver [min-ver] [cur-ver]
# return 0 if current ver >= min ver.
chk_ver() {
	[  "$1" = "$(printf -- "$1\n$2\n" | sort -V | head -n1)" ]
}

backtrace() {
	TRACE=""
	CP=$$ # PID of the script itself [1]

	while true # safe because "all starts with init..."
	do
			CMDLINE=$(cat /proc/$CP/cmdline)
			PP=$(grep PPid /proc/$CP/status | awk '{ print $2; }') # [2]
			TRACE="$TRACE [$CP]:$CMDLINE\n"
			if [ "$CP" == "1" ]; then # we reach 'init' [PID 1] => backtrace end
					break
			fi
			CP=$PP
	done
	echo "Backtrace of '$0'"
	echo -en "$TRACE" | tac | grep -n ":" # using tac to "print in reverse" [3]
}
