#!/usr/bin/env bash

# chk_ver [min-ver] [cur-ver]
# return 0 if current ver >= min ver.
chk_ver() {
	[  "$1" = "$(printf -- "$1\n$2\n" | sort -V | head -n1)" ]
}
