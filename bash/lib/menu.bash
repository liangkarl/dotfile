#!/usr/bin/env bash

vars=(
	"__m_title"
	"__m_prompt"
	"__m_defopt"
	"__m_backend"
	"__m_callback"
	"__m_cancel"
	"__m_exit"
	"__m_view"
	"__m_width"
	"__m_height"
	"__m_sel_idx"
	"__m_sel_opt"
)

for f in ${vars[@]}; do
	eval "function ${f//__m_/menu.}() {
		if [[ \$# -eq 0 ]]; then
			echo \"\$$f\"
			return
		fi

		$f="\$1"
	}"
done
unset vars

menu.opts() {
	if [[ $# -eq 0 ]]; then
		echo "${__m_opts[@]}"
		return
	fi

	__m_opts=("$@")
}

menu.reset() {
	unset __m_defopt
	unset __m_title
	unset __m_prompt
	unset __m_input
	unset __m_callback
	unset __m_cancel
	unset __m_exit
	unset __m_view
	unset __m_width
	unset __m_sel_idx
	unset __m_sel_opt
	__m_height=10
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
		return 1
	fi

	if [[ -n "$__m_view" ]]; then
		eval menu.view
		return
	fi

	sel="$(menu.${__m_backend})"

	__m_sel_idx="$sel"
	__m_sel_opt="${__m_opts[$sel]}"
	if [[ -n "$__m_callback" ]]; then
		eval $__m_callback $__m_sel_idx $__m_sel_opt
	fi

	if [[ "${__m_opts[$sel]}" == "exit" ]]; then
		exit
	fi
}

menu.fzf() {
	local fzf sel i

	fzf=("$(which fzf)" "--height=~${__m_height}" "--cycle")

	if [[ -n "$__m_defopt" ]]; then
		fzf+=("--query=${__m_opts[$__m_defopt]}")
	fi

	if [[ -n "$__m_title" ]]; then
		fzf+=("--header='${__m_title}'")
	fi

	if [[ -n "$__m_prompt" ]]; then
		fzf+=("--prompt='${__m_prompt}: '")
	fi

	sel=$(eval "echo ${__m_opts[@]// /%} | sed -e 's/ /\n/g' -e 's/%/ /g' | ${fzf[*]}")

	for i in "${!__m_opts[@]}"; do
		if [[ "${__m_opts[$i]}" == "$sel" ]]; then
			echo "$i"
			return
		fi
	done
}

menu.fzf-tmux() {
	local fzf sel i

	fzf=("$(which fzf-tmux)" "-p" "-h ${__m_height}" "--")

	if [[ -n "$__m_defopt" ]]; then
		fzf+=("--query=${__m_opts[$__m_defopt]}")
	fi

	if [[ -n "$__m_title" ]]; then
		fzf+=("--header=${__m_title}")
	fi

	if [[ -n "$__m_prompt" ]]; then
		fzf+=("--prompt=${__m_prompt}: ")
	fi

	sel=$(eval "echo ${__m_opts[@]// /%} | sed -e 's/ /\n/g' -e 's/%/ /g' | ${fzf[*]}")

	for i in "${!__m_opts[@]}"; do
		if [[ "${__m_opts[$i]}" == "$sel" ]]; then
			echo "$i"
			return
		fi
	done
}

menu.fzy() {
	local fzy

	fzy=("fzy" "--lines=${__m_height}")

	if [[ -n "$__m_defopt" ]]; then
		fzy+=("-q ${__m_opts[$__m_defopt]}")
	fi

	# output nothing is no title available
	printf "$__m_title"

	sel=$(eval "echo ${__m_opts[@]// /%} | sed -e 's/ /\n/g' -e 's/%/ /g' | ${fzy[*]}")

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

	styles=('fzf-tmux' 'fzf' 'fzy' 'legacy')

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
