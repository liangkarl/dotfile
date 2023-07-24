#!/usr/bin/env bash

menu_reinit() {
	__menu_title=
	__menu_prompt=
	__menu_choice=
	__menu_default=
	__menu_default_text=
	__menu_style=
}

menu_style() {
	local styles

	styles=('fzf' 'fzy' 'legacy')

	if grep -q "$1" <<< "${style[@]}"; then
		__menu_style="$1"
	elif [[ "$1" == "auto" ]]; then
		if type -p fzy; then
			__menu_style="fzy"
		elif type -p fzf; then
			__menu_style="fzf"
		else
			__menu_style="legacy"
		fi &> /dev/null
	else
		__menu_style="legacy"
		echo "Found invalid menu style, $1. Set to '$__menu_style'"
	fi
}

menu_choice() {
	echo $__menu_choice
}

menu_default() {
	__menu_default="$1"
	__menu_default_text="($__menu_default) "
}

menu_title() {
	__menu_title="$*\n"
}

menu_prompt() {
	__menu_prompt="$*"
}

menu_show() {
	local i item

	# output nothing is no title available
	printf "$__menu_title"

	for item in "$@"; do
		echo "$((++i))) $item"
	done
}

menu_legacy() {
	local item opts ans

	menu_show "$@"

	while :; do
		read -p "$__menu_prompt $__menu_default_text" ans
		ans=${ans:-$__menu_default}

		if [[ -z "$ans" ]]; then
			echo "empty input"
		elif [[ ! $ans =~ ^[0-9]+$ ]]; then
			echo "not a number. ($ans)"
		elif (( ans <= 0 || ans > $# )); then
			echo "an illegal value. ($ans)"
		else
			break
		fi
	done

	opts=("$@")
	__menu_choice="${opts[$((ans-1))]}"
}

menu_fzf() {
	local fzf

	fzf=("fzf" "--height=~10" "--cycle")
	if [[ -n "$__menu_default" ]]; then
		fzf+=("-q ${!__menu_default}")
	fi

	# output nothing is no title available
	printf "$__menu_title"
	__menu_choice="$(echo ${@// /%} \
			| sed -e 's/ /\n/g' -e 's/%/ /g' \
			| ${fzf[*]})"
}

menu_fzy() {
	local fzy

	fzy=("fzy" "--lines=10")
	if [[ -n "$__menu_default" ]]; then
		fzy+=("-q ${!__menu_default}")
	fi

	# output nothing is no title available
	printf "$__menu_title"
	__menu_choice="$(echo ${@// /%} \
			| sed -e 's/ /\n/g' -e 's/%/ /g' \
			| ${fzy[*]})"
}

menu_select() {
	if [[ -z "$__menu_style" ]]; then
		menu_style auto
	fi
	menu_${__menu_style} "$@"
}

menu_reinit
