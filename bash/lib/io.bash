#!/usr/bin/env bash

if (( $(tput colors) == 256 )); then
	# print text with green color
	pr_good() { echo -e "\033[1;32m$@\033[0m"; }
	# print text with white color
	pr_hint() { echo -e "\033[1;37m$@\033[0m"; }
	# print text with yellow color
	pr_warn() { echo -e "\033[1;33m$@\033[0m"; }
	# print text with red color
	pr_err() { echo -e "\033[1;31m$@\033[0m"; }
else
	pr_good() { echo -e "$@"; }
	pr_hint() { echo -e "$@"; }
	pr_warn() { echo -e "$@"; }
	pr_err() { echo -e "$@"; }
fi

pr_bad() { pr_err $@; }
pr_info() { echo -e "$@"; }

# !0: error out
# 0: normal out
# $0 code "string"
exit_msg() {
	local r

	r=$1
	shift

	if (( $r != 0 )); then
		pr_err $@
	else
		pr_info $@
	fi

	exit $r
}
