#!/usr/bin/env bash

menu.reset() {
	unset __m_defopt
	unset __m_title
	unset __m_prompt
	unset __m_input
	unset __m_callback
	unset __m_cancel
	unset __m_exit
	unset __m_view
	__m_opts=()
	__m_backend='fzf'
}

menu.add_cancel() {
	__m_cancel=y
	__m_opts+=("cancel")
}

menu.add_exit() {
	__m_exit=y
	__m_opts+=("exit")
}

menu.view_only() {
	__m_view=y
	__m_backend='legacy'
}

menu.run() {
	local index input sel

	if [[ -z "$__m_opts" ]]; then
		echo "No opts exist." >&2
		return
	fi

	if [[ -n "$__m_view" ]]; then
		eval menu.view;
		return
	fi

	sel="$(menu.${__m_backend})"

    if [[ -n "$__m_callback" ]]; then
		eval $__m_callback $sel ${__m_opts[$sel]}
	fi
}

menu.title() {
	if [[ $# -eq 0 ]]; then
		echo "$__m_title"
		return
	fi

	__m_title="$1"
}

menu.prompt() {
	if [[ $# -eq 0 ]]; then
		echo "$__m_prompt"
		return
	fi

	__m_prompt="$1"
}

menu.defopt() {
	if [[ $# -eq 0 ]]; then
		echo "$__m_defopt"
		return
	fi

	__m_defopt="$1"
}

menu.backend() {
	if [[ $# -eq 0 ]]; then
		echo "$__m_backend"
		return
	fi

	__m_backend="$1"
}

menu.opts() {
	if [[ $# -eq 0 ]]; then
		echo "${__m_opts[@]}"
		return
	fi

	__m_opts=("$@")
}

menu.cb() {
	if [[ $# -eq 0 ]]; then
		echo "$__m_callback"
		return
	fi

	__m_callback="$1"
}

menu.fzf() {
	local fzf sel i

	fzf=("$(which fzf)" "--height=~10" "--cycle")

	if [[ -n "$__m_defopt" ]]; then
		fzf+=("--query=${__m_opts[$__m_defopt]}")
	fi

	if [[ -n "$__m_title" ]]; then
		fzf+=("--header=${__m_title}")
	fi

	if [[ -n "$__m_prompt" ]]; then
		fzf+=("--prompt=${__m_prompt}: ")
	fi

	sel="$(echo ${__m_opts[@]// /%} \
			| sed -e 's/ /\n/g' -e 's/%/ /g' \
			| ${fzf[*]} 2>&1)"

	for i in "${!__m_opts[@]}"; do
		if [[ "${__m_opts[$i]}" == "$sel" ]]; then
			echo "$i"
			return
		fi
	done
}

menu.fzy() {
	local fzy

	fzy=("fzy" "--lines=10")

	if [[ -n "$__m_defopt" ]]; then
		fzy+=("-q ${__m_opts[$__m_defopt]}")
	fi

	# output nothing is no title available
	printf "$__m_title"

	sel="$(echo ${__m_opts[@]// /%} \
			| sed -e 's/ /\n/g' -e 's/%/ /g' \
			| ${fzy[*]} 2>&1)"

	for i in "${!__m_opts[@]}"; do
		if [[ "${__m_opts[$i]}" == "$sel" ]]; then
			echo "$i"
			return
		fi
	done
}

menu._view() {
	local i opt

	printf -- "$__m_title" > /dev/tty

	for opt in "${__m_opts[@]}"; do
		echo "$((i++))) $opt"
	done > /dev/tty
}

menu.legacy() {
	local item opts ans prompt

	menu._view

	if [[ -n "$__m_defopt" ]]; then
		prompt="$__m_prompt ($__m_defopt):"
	else
		prompt="$__m_prompt:"
	fi
	while :; do
		read -p "${prompt} " ans
		ans=${ans:-$__m_defopt}

		if [[ -n "$ans" ]] && (( ans >= 0 && ans < ${#__m_opts[@]})); then
			break
		fi 2>&-
	done

	echo "$ans"
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

menu.reset
