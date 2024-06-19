#!/usr/bin/env bash

if (( $(tput colors) == 256 )); then
	# print text with green color
	pr_good() { printf -- "\033[1;32m$*\033[0m\n"; }
	# print text with white color
	pr_hint() { printf -- "\033[1;37m$*\033[0m\n"; }
	# print text with yellow color
	pr_warn() { printf -- "\033[1;33m$*\033[0m\n"; }
	# print text with red color
	pr_err() { printf -- "\033[1;31m$*\033[0m\n"; }
else
	pr_good() { printf -- "$*\n"; }
	pr_hint() { printf -- "$*\n"; }
	pr_warn() { printf -- "$*\n"; }
	pr_err() { printf -- "$*\n"; }
fi

pr_bad() { pr_err $*; }
pr_info() { printf -- "$*\n"; }

# !0: error out
# 0: normal out
# $0 code "string"
exit_msg() {
	local r

	r=$1
	shift

	if (( $r != 0 )); then
		pr_err "$*"
	else
		pr_info "$*"
	fi

	exit $r
}
