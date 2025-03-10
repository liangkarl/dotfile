#!/usr/bin/env bash

__MENU_BASH_FUNCS_BEFORE="$(compgen -A function) $(compgen -v)"

__m_height=${__m_height:-10}
__m_opts=("${__m_opts[@]}")
__m_backend=${__m_backend:-fzf}

vars=(
	"__m_title"
	"__m_prompt"
	"__m_defopt"
	"__m_backend"
	"__m_callback"
	"__m_view"
	"__m_width"
	"__m_height"
	"__m_ans_idx"
	"__m_ans_opt"
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
unset vars f

# TODO:
# 1. Add multiple name space, making reinit menu unnecessary.
# 2. Use eval to dynamically create the vars of multiple name space.

menu.opts() {
	if [[ $# -eq 0 ]]; then
		echo "${__m_opts[@]}"
		return
	fi

	__m_opts=("$@")
}

menu.add_opt() {
	__m_opts+=("$1")
}

menu.result() {
	menu.ans_idx
	menu.ans_opt
}

menu.reset() {
	unset __m_defopt
	unset __m_title
	unset __m_prompt
	unset __m_input
	unset __m_callback
	unset __m_view
	unset __m_width
	unset __m_ans_idx
	unset __m_ans_opt
}

menu.view_only() {
	__m_view=y
	__m_backend='legacy'
}

menu.run() {
	local index input idx

	if [[ -z "$(menu.opts)" ]]; then
		echo "No opts exist." >&2
		return 1
	fi

	if [[ -n "$(menu.view)" ]]; then
		menu.view
		return
	fi

	idx="$(menu.$(menu.backend))"
	if [[ -z "$idx" ]]; then
		menu.ans_idx "-1"
		menu.ans_opt ""
		return 1
	fi

	menu.ans_idx "$idx"
	menu.ans_opt "${__m_opts[$idx]}"

	if [[ -n "$(menu.callback)" ]]; then
		eval "$(menu.callback) $(menu.ans_idx) $(menu.ans_opt)"
	fi
}

menu.fzf() {
	local fzf opt i

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

	opt=$(eval "echo ${__m_opts[@]// /%} | sed -e 's/ /\n/g' -e 's/%/ /g' | ${fzf[*]}")

	for i in "${!__m_opts[@]}"; do
		if [[ "${__m_opts[$i]}" == "$opt" ]]; then
			echo "$i"
			return
		fi
	done
}

menu.fzf-tmux() {
	local fzf opt i

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

	opt=$(eval "echo ${__m_opts[@]// /%} | sed -e 's/ /\n/g' -e 's/%/ /g' | ${fzf[*]}")

	for i in "${!__m_opts[@]}"; do
		if [[ "${__m_opts[$i]}" == "$opt" ]]; then
			echo "$i"
			return
		fi
	done
}

menu.fzy() {
	local fzy opt

	fzy=("fzy" "--lines=${__m_height}")

	if [[ -n "$__m_defopt" ]]; then
		fzy+=("-q ${__m_opts[$__m_defopt]}")
	fi

	# output nothing is no title available
	printf "$__m_title"

	opt=$(eval "echo ${__m_opts[@]// /%} | sed -e 's/ /\n/g' -e 's/%/ /g' | ${fzy[*]}")

	for i in "${!__m_opts[@]}"; do
		if [[ "${__m_opts[$i]}" == "$opt" ]]; then
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
menu.reset

__MENU_BASH_FUNCS_AFTER="$(compgen -A function) $(compgen -v)"

if [[ -n "$__MENU_BASH_FUNCS_DIFF" ]]; then
    msg.dbg "${BASH_SOURCE[1]}: use old diff table"
else
    # time __DEVEL_BASH_FUNCS_DIFF=$(comm -23 <(printf "%s\n" $' '"$__DEVEL_BASH_FUNCS_AFTER" | sort) <(printf "%s\n" $' '"$__DEVEL_BASH_FUNCS_BEFORE" | sort))
    # time __DEVEL_BASH_FUNCS_DIFF=$(printf "%s\n" $__DEVEL_BASH_FUNCS_AFTER | grep -Fvx -f <(printf "%s\n" $__DEVEL_BASH_FUNCS_BEFORE))
    __MENU_BASH_FUNCS_DIFF=$(awk 'NR==FNR {a[$0]=1; next} !($0 in a)' <(printf "%s\n" $__MENU_BASH_FUNCS_BEFORE) <(printf "%s\n" $__MENU_BASH_FUNCS_AFTER))
fi
unset __MENU_BASH_FUNCS_AFTER __MENU_BASH_FUNCS_BEFORE
