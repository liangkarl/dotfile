#!/usr/bin/env bash

lib.load devel
lib.load config

# GLOBAL CONFIGURATION FORMAT:
#
# # general
# C=commit
# BR=branch
# ...
#
# # optional: push, paste
# DST_C
#
# # optional: patch generation
# PATCH='xxx yyy zzz'

topdir="$(git rev-parse --show-toplevel)"
gitdir="$(
	if [[ -f "${dir}" ]]; then
		echo $(cat $dir | awk -F: '{print $2}')/.git
	else
		echo ${topdir}/.git
	fi
)"
tmpdir='/tmp/tig'
node="${tmpdir}/node"
commits=${tmpdir}/tig.commits
infos=${tmpdir}/tig.save
stage_change=${tmpdir}/stage.diff
unstage_change=${tmpdir}/unstage.diff
p_opts='--binary --histogram'
patchdir=${topdir}/git-patch
CUR_BR=$(git branch --show-current)

PREFIX_TAG='refs/tags'
PREFIX_BR='refs/heads'
PREFIX_REMOTE='refs/remotes'
PREFIX_STASH='refs/stash'
PREFIX_SELECT="${PREFIX_TAG}/select"
MENU='input -o menu'
INPUT='input'

declare -A git_actions=(
	[rebase-merge]=rebase
	[rebase-apply]=rebase
	[MERGE_HEAD]=merge
	[REVERT_HEAD]=revert
	[CHERRY_PICK_HEAD]=cherry-pick
)


mkdir $tmpdir 2> $__N

show_cmd() {
	local ret
	if $*; then
		echo "'$*' done"
	else
		ret=$?
		echo "'$*' failed ($ret)"
		return $ret
	fi
}

conv_name() {
	sed 'y/ :()/-___/; s/!//g; s/[-_]*_[-_]*/_/g'
}

git.msg() { show_cmd git $*; }

git.auto() {
	local list="stash rebase merge cherry-pick revert"
	local change

	change=$(git status --porcelain | grep -v '^??')
	if [[ -n "$change" ]]; then
		git stash
	fi

	if ! git.msg $*; then
		if grep -q $1 <<< $list; then
			git.msg $1 --abort
		fi
	fi

	if [[ -n "$change" ]] && action.check; then
		git stash pop stash@{0} || echo "failed to restore unchecked changes"
	fi
}

has_conflict() {
	[[ $(git diff --name-only --diff-filter=U | wc -l) -ne 0 ]]
}

dump_refs() {
	git for-each-ref $1 \
		--format='refname=%(refname)
			short=%(refname:short)
			objectname=%(objectname)
			subject=%(contents:subject)
			upstream=%(upstream:short)
			upstream_track=%(upstream:track)
			remote=%(upstream:remotename)
			objecttype=%(objecttype)
			tagger=%(taggername)
			taggerdate=%(taggerdate)'
}

dump_remote_branch() {
	git for-each-ref ${PREFIX_REMOTE}/$1 \
		--format='refname=%(refname)
			short=%(refname:short)
			objectname=%(objectname)
			subject=%(contents:subject)'
}

dump_tag() {
	git for-each-ref ${PREFIX_TAG}/$1 \
		--format='refname=%(refname)
			short=%(refname:short)
			objectname=%(objectname)
			subject=%(contents:subject)'
}

# is_commit <sha>
is_commit() { git rev-parse --verify --quiet ${1} &> $__N; }
# is_branch <branch>
is_branch() { git show-ref --verify --quiet ${PREFIX_BR}/${1} &> $__N; }
# is_tag TAG
is_tag() {
	git show-ref --verify --quiet ${PREFIX_TAG}/${1} && return
	[[ "$1" =~ ${PREFIX_TAG}/ ]] || return $?
	git show-ref --verify --quiet ${1}
} &> $__N
# is_remote_branch <refname>
is_remote_branch() { git show-ref --verify --quiet ${PREFIX_REMOTE}/${1} &> $__N; }
is_stash() {
	local commit

    commit=$(git rev-parse --verify "$1^{commit}" 2>/dev/null) ||
        return 2

    git reflog show --format='%H' refs/stash 2>/dev/null |
        grep -Fxq "$commit"
}

# to_sha <tag|branch>
to_sha() { git rev-parse $1 2> $__N; }

what_action() {
	local state path line

	git rev-parse --git-dir &>/dev/null || return 2

	for state in "${!git_actions[@]}"; do
		path=$(git rev-parse --git-path "$state") || return 2

		if [[ -e $path ]]; then
			printf '%s\n' "${git_actions[$state]}"
			return 0
		fi
	done

	# Multi-commit cherry-pick/revert.
	path=$(git rev-parse --git-path sequencer/todo) || return 2

	if [[ -f $path ]]; then
		while read -r line; do
			case $line in
				pick\ *)
					printf '%s\n' cherry-pick
					return 0
					;;
				revert\ *)
					printf '%s\n' revert
					return 0
					;;
			esac
		done < "$path"
	fi

	return 1
}

# FILE=%(file) C=%(commit) file.checkout
file.checkout() {
    true
}

# NAME= delete
delete() {
	name=$NAME
	if [[ -z "$name" ]]; then
		echo "Cancelled"
		return 1
	fi

	target=$(while [[ "$name" != '.' ]]; do
		echo "$name"
		name=$(dirname $name)
	done | $MENU -p 'Delete Target:')

	if [[ -z "$target" ]]; then
		echo "Cancelled"
		return 1
	fi

	rm -vr $target
}

# br.add() {
#
# }
#
# tag.add() {
#
# }

# Check remote branch
# get_remote_branch <branch>
find_remote_branch() {
	local remote

	if ! is_commit $1; then
		return 1
	fi

	remote=$(git rev-parse --abbrev-ref ${1}@{upstream} &> $__N)

	if [ -n "$remote" ]; then
		echo $remote
	else
		return 2
	fi
}

# To know which is the last action
# rebase/merge/am/revert/cherry-pick
_load_last_action() {
	local cmd
}

# stash.save
stash.save() {
	local repo="$(basename $topdir)"
	local sha="$(git rev-parse --short HEAD)"

	NAME=$($INPUT -t "New Stash Name: [[STAGE/UNSTAGE]: {repo}.${sha}]")
	case "$TYPE" in
	stage)
		git.msg stash save --staged ${NAME:-STAGE: ${repo}.${sha}}
		;;
	unstage)
		git.msg stash save --keep-index ${NAME:-UNSTAGE: ${repo}.${sha}}
		;;
	*)
		git.msg stash save ${NAME:-${repo}.${sha}}
	esac
}

# NAME= stash.pop
stash.pop() {
	if [[ $(git stash list | wc -l) -eq 0 ]]; then
		echo "No stash found"
		return
	fi

	rm -f ${stage_change} ${unstage_change}

	if ! git diff --quiet; then
		echo "Backup unstage change(s)"
		git diff --binary --patience > ${unstage_change}
	fi

	# stage changes if exist
	if ! git diff --cached --quiet; then
		echo "Backup stage change(s)"
		git diff --cached --binary --patience > ${stage_change}
	fi

	if git.msg stash apply stash@{0}; then
		git.msg stash drop stash@{0}
	else
		if has_conflict; then
			echo "Conflict(s):"
			git diff
		fi

		echo "Recover previous change(s)"
		git reset --hard

		if [[ -e ${stage_change} ]]; then
			git apply --verbose ${stage_change}
			git add -u
		fi

		if [[ -e ${unstage_change} ]]; then
			git apply --verbose ${unstage_change}
		fi
	fi
}

#C= [NAME=] refs.move
refs.move() {
	local opts opt
	declare -A opts

	is_commit "$C" || return 1

	TYPE=${TYPE:-$($MENU -p 'How to move? ' simple-move rebase merge)}
	if [[ -z "$TYPE" ]]; then
		echo "No type selected"
		return 2
	fi

	case "$TYPE" in
	simple-move)
		NAME=${NAME:-$(git for-each-ref --format='%(refname)' refs/heads refs/tags | $MENU -p 'Move which refs?')}
		git update-ref -d $NAME
		git.msg update-ref $NAME $C
		;;
	rebase)
		opts=(
			[other-refs]=''
			[onto]="--onto $C "
			[edit]='-i '
		)
		while read -r item; do
			if [[ -z "$item" ]]; then
				echo "cancelled"
				exit
			fi
			if [[ "$item" == none ]]; then
				break
			fi
			if [[ "$item" == onto ]]; then
				ONTO=y
			fi
			if [[ "$item" == other-refs ]]; then
				OTHER_REFS=y
			fi
			opt+="${opts[$item]} "
		done <<< $($MENU -o multi -p 'Options?' none "${!opts[@]}")

		if [[ "$OTHER_REFS" == y ]]; then
			END=${NAME:-$(git for-each-ref --format='%(refname)' refs/heads | $MENU -p 'Move which refs?')}
		fi
		if [[ "$ONTO" == y ]]; then
			FROM_IDX=${FROM:-$(git log --pretty=slog $END | $MENU -o value -p 'From?')}
			git.msg rebase $opt ${END:-HEAD}~$FROM_IDX $END
		else
			git.msg rebase $opt $C $END
		fi
		;;
	merge)
		;;
	*)
	esac
}

# [TYPE=] [NAME=] C= refs.create
refs.create() {
	is_commit "$C" || return 1

	TYPE=${TYPE:-$($MENU -p 'Add What? ' branch tag refs)}
	if [[ -z "$TYPE" ]]; then
		echo "No type selected"
		return 2
	fi

	case "$TYPE" in
	branch)
		NAME=${NAME:-$($INPUT -t "What's its name? [Enter to skip]" | conv_name)}
		NAME=${NAME:-$(basename "$(git rev-parse --show-toplevel)")}
		git.msg branch $NAME $C
		;;
	tag)
		NAME=${NAME:-$($INPUT -t "What's its name? [Enter to skip]" | conv_name)}
		NAME=${NAME:-tag.$(git rev-parse --short $C)}
		git.msg tag $NAME $C
		;;
	# save-refs)
	# 	config.load $node
	# 	config.get NAME REFS
	# 	if [[ -n "$NAME" ]]; then
	# 		git.msg update-ref $NAME $C
	# 	fi
	# 	rm $node
	# 	;;
	refs)
		NAME=${NAME:-$($INPUT -t "What's the refs name? [refs/tags/tag.$(git rev-parse --short $C)]")}
		NAME=${NAME:-refs/tags/tag.$(git rev-parse --short $C)}
		git.msg update-ref $NAME $C
		;;
	*)
		echo "Unknown type $TYPE"
		return 4
	esac
}

# TAG=|BR= C= [TYPE=[local|remote]] refs.verify
refs.verify() {
	is_commit "$C" || return 1

    if [[ -n "$TAG" ]] && is_tag "$TAG"; then
        [ "$(to_sha ${PREFIX_TAG}/${TAG})" == "$(to_sha $C)" ]
        return $?
    elif [[ -n "$BR" ]] && is_branch "$BR"; then
        [ "$(to_sha ${PREFIX_BR}/${BR})" == "$(to_sha $C)" ]
        return $?
    fi

    return 3
}

# C= TYPE=tag|branch UP= refs.find
refs.find() {

	is_commit "$C" || return 1

	case "$TYPE" in
	tag)
		rev=${PREFIX_TAG}
		prompt='Select Tag: '
		;;
	branch)
		rev=${PREFIX_BR}
		prompt='Select Branch: '
		;;
	all)
		rev="${PREFIX_BR} ${PREFIX_TAG}"
		prompt='Select Ref: '
		;;
	*)
		echo "unsupport type $TYPE" >&2
		return 2
	esac

	list="$(git for-each-ref --points-at $C $rev --format='%(refname)')"
	count=$(printf "${list:+${list}\n}" | wc -l)
	if [[ $count -gt 1 ]]; then
		printf "$list" | $MENU -p "$prompt"
	else
		echo $list
	fi
}

# C= REFS= refs.rename
refs.rename() {
	is_commit "$C" || return 1

	if [[ -z "$REFS" ]]; then
		REFS=$(C=$C TYPE=all refs.find)
		if [[ -z "$REFS" ]]; then
			echo "no branch or tag available"
			return 2
		fi
	fi

	NAME=$($INPUT -t "Rename To:" | conv_name)
	if [[ -z "$NAME" ]]; then
		echo "no name specified"
		return 3
	fi

	if is_tag $REFS; then
		if ! grep -q "${PREFIX_TAG}/" <<< $REFS; then
			REFS="${PREFIX_TAG}/$REFS"
		fi
		NAME="${PREFIX_TAG}/$NAME"
		git update-ref -d $REFS
		git.msg update-ref $NAME $C
	else
		git.msg branch -m "${REFS##${PREFIX_BR}/}" "$NAME"
	fi
}

# C= [REFS=] refs.cut
# TODO: add cutting remove branchs & tags
refs.cut() {
	if [[ -z "$REFS" ]]; then
		is_commit "$C" || return 1

		REFS=$(C=$C TYPE=all refs.find)
		if [[ -z "$REFS" ]]; then
			echo "no branch or tag available"
			return 2
		fi
	else
		if [[ ! "$REFS" =~ $PREFIX_TAG/* ]]; then
			REFS=$(git for-each-ref --format='%(refname)' $PREFIX_BR $PREFIX_TAG | grep -E "^*/${REFS}$")
		fi
	fi

	rm -f $node
	config.load $node
	if [[ -n "$REMOTE" ]]; then
		# $REF only supports remote branch
		if is_remote_branch "${REMOTE}/${BR}"; then
			git push -d $REMOTE $BR
			config.set "BR" "$BR"
		else
			echo "invalid remote branch: ${REMOTE}/${BR}"
		fi
	elif [[ -n "$REFS" ]]; then
		if [[ ${PREFIX_BR}/${CUR_BR} == $REFS ]]; then
			echo "Cannot remove current branch"
			return 1
		fi
		git update-ref -d $REFS
		config.set "REFS" "$REFS"

		echo "Cut: $REFS"
		if [[ "${REFS##${PREFIX_TAG}}" =~ select\/[0-9]+ ]]; then
			select.refresh
			return
		fi
	fi
	config.save
}

# [C=|BR= TAG=] $OPT refs.push()
refs.push() {
	local cmd
	local opts

	act="$($MENU -p 'Select Action:' Create Update)"
	[[ -z "$act" ]] && { echo "cancelled"; return; }

	remote=$(git remote)
	if [[ $(git remote | wc -l) -gt 1 ]]; then
		remote=$($MENU -p 'Select Remote:' $(git remote))
	fi

	if [[ -n "$C" ]]; then
		src="$C"

		if [[ "$act" == "Create" ]]; then
			name="$($INPUT -t "Name?")"
			[[ -z "$name" ]] && { echo "cancelled"; return; }

			obj="$($MENU -p 'Type?' Branch Tag)"
			[[ -z "$obj" ]] && { echo "cancelled"; return; }

			if [[ "$obj" == "Tag" ]]; then
				obj="refs/tags/${name}"
			elif [[ "$obj" == "Branch" ]]; then
				obj="refs/heads/${name}"
			fi
		fi

	elif [[ -n "$BR$TAG" ]]; then
		src="$BR$TAG"

		if [[ "$act" == "Create" ]]; then
			name="$($INPUT -t "Name? [$BR$TAG]")"
			name="${name:-$BR$TAG}"
			if [[ -n "$BR" ]]; then
				obj="refs/heads/${name}"
			elif [[ -n "$TAG" ]]; then
				obj="refs/tags/${name}"
			fi
		fi
	fi

	if [[ "$act" == "Update" ]]; then
		obj="$(git ls-remote -t -b origin | awk '{print $2}' | $MENU -p 'Which one?')"

		force="$($INPUT -t 'Force? [y/N]')"
		force="${force:-n}"
		if [[ "$force" == y ]]; then
			OPT='--force-with-lease'
		fi
	fi

	git.msg push $OPT $remote ${src}:${obj}
}

# copy <text>
copy() {
	local cmd
	if cmd.has xclip; then
		cmd="xclip"
	elif cmd.has pbcopy; then
		cmd="pbcopy"
	else
		echo "no valid copy tools"; false
		return
	fi

	echo -n "$TEXT" | $cmd
	echo "copy '$TEXT'"
}

# TYPE= C= patch.create
patch.create() {
	local opts

	opts="diff commit stage stash select-patch select-range"
	[[ ! -d "$patchdir" ]] && mkdir ${patchdir}

	if [[ -z "$TYPE" ]]; then
		TYPE=$($MENU -p "Generate Patch(es) From:" $opts)
	fi


	i=100
	out="${patchdir}/"
	case "$TYPE" in
	diff)
		FILE="$({ echo "ALL"; git diff --name-only; } | $MENU -p "Pick File(s):")"
		[[ "$FILE" == "ALL" ]] && unset FILE
		NAME="$($INPUT -t "Patch Name?" | conv_name)"
		out+=${NAME:-$(date +%y%m%d-%H%M%S)}.patch
		git diff $p_opts ${FILE+-- $FILE} | tee ${out}
		;;
	stage)
		FILE="$({ echo "ALL"; git diff --name-only --cached; } | $MENU -p "Pick File(s):")"
		[[ "$FILE" == "ALL" ]] && unset FILE
		NAME="$($INPUT -t "Patch Name?" | conv_name)"
		out+=${NAME:-$(date +%y%m%d-%H%M%S)}.patch
		git diff --cached $p_opts ${FILE+-- $FILE} | tee ${out}
		;;
	stash)
		if ! is_stash $C; then
			C=$(git stash list | $MENU -p "Select Stash:" | cut -d: -f1)
			[[ -z "$C" ]] && return 2
		fi
		FILE="$({ echo "ALL"; git stash show --name-only $C; } | $MENU -p "Pick File(s):")"
		[[ "$FILE" == "ALL" ]] && unset FILE
		NAME="$($INPUT -t "Patch Name?" | conv_name)"
		out+=${NAME:-$(date +%y%m%d-%H%M%S)}.patch
		git stash show $p_opts -p $C ${FILE+-- $FILE} | tee ${out}
		;;
	commit)
		if ! is_commit $C || is_stash $C; then
			C=$(git log --oneline | $MENU -p "Select Commit:" | cut -d: -f1)
			[[ -z "$C" ]] && return 2
		fi
		FILE="$({ echo "ALL"; git show --pretty='' --name-only $C; } | $MENU -p "Pick File(s):")"
		[[ "$FILE" == "ALL" ]] && unset FILE
		out+=${NAME:-$(date +%y%m%d-%H%M%S)}.patch
		git show $p_opts $C ${FILE+-- $FILE} | tee ${out}
		;;
	select-patch)
		local item i

		if [[ ! -e $commit ]]; then
			return 2
		fi
		for item in $(cat $commits); do
			git.msg format-patch --start-number $((i++)) -k $p_opts -1 -o ${patchdir} $item
		done &> $__N

		select.reset
		;;
	select-range)
		if [[ ! -e $commit ]]; then
			return 2
		fi

		beg=$(head -n 1 $commit)

		if [[ "$(wc -l $commits | cut -d' ' -f1)" -ge 2 ]]; then
			end=$(tail -n 1 $commit)
		else
			end=HEAD
		fi

		if git format-patch -o ${patchdir} -k $p_opts ${beg}..${end}; then
			echo "$((i - 100)) patch(es) has been created."
		else
			echo "Failed to create patch(es)"
		fi
		select.reset
		;;
	*)
		echo "unknown type $TYPE"
	esac
}

# C= commit.versions
commit.versions() {
	local commit reflog line old new message i changed stat
	local -a old_commits=() new_commits=() versions=()
	local -A found=() added=()

	commit=$(git rev-parse --verify --quiet "${C}^{commit}") || {
		echo "Invalid commit: $C" >&2
		return 1
	}
	reflog=$(git rev-parse --git-path logs/HEAD) || return 1
	if [[ ! -r "$reflog" ]]; then
		echo "HEAD reflog is not available" >&2
		return 1
	fi

	while IFS= read -r line; do
		message=${line#*$'\t'}
		[[ "$message" == 'commit (amend): '* ]] || continue
		read -r old new _ <<< "$line"
		old_commits+=("$old")
		new_commits+=("$new")
	done < "$reflog"

	found["$commit"]=1
	while :; do
		changed=0
		for ((i=0; i<${#old_commits[@]}; i++)); do
			old=${old_commits[i]}
			new=${new_commits[i]}
			if [[ -n ${found[$old]} || -n ${found[$new]} ]]; then
				if [[ -z ${found[$old]} || -z ${found[$new]} ]]; then
					found["$old"]=1
					found["$new"]=1
					changed=1
				fi
			fi
		done
		(( changed )) || break
	done

	for ((i=${#old_commits[@]}-1; i>=0; i--)); do
		for commit in "${new_commits[i]}" "${old_commits[i]}"; do
			if [[ -n ${found[$commit]} && -z ${added[$commit]} ]] &&
				git cat-file -e "${commit}^{commit}" 2>/dev/null; then
				versions+=("$commit")
				added["$commit"]=1
			fi
		done
	done

	if (( ${#versions[@]} < 2 )); then
		echo "No available amend versions found in the HEAD reflog"
		return 1
	fi
	printf 'Amend versions (newer -> older):\n\n'
	git --no-pager log --no-walk=unsorted --format=medium "${versions[@]}" || return
	printf '\nChanges between versions (older -> newer):\n'
	for ((i=1; i<${#versions[@]}; i++)); do
		old=${versions[i]}
		new=${versions[i-1]}
		stat=$(git diff --stat "$old" "$new") || return
		printf '\n%s -> %s:\n%s\n' "${old:0:12}" "${new:0:12}" "${stat:- no file changes}"
	done
}

# [TYPE=] commit.create
commit.create() {
	local item list opts

	declare -A opts
	opts=(
		[amend]='--amend'
		[no-edit]='--no-edit'
	)
	TYPE=${TYPE:-$($MENU -p 'What type?' just-commit select-patch merge-pick reuse-msg)}
	case "$TYPE" in
	just-commit)
		opt='-v '
		while read -r item; do
			if [[ -z "$item" ]]; then
				echo "cancelled"
				exit
			fi
			if [[ "$item" == none ]]; then
				break
			fi
			opt+="${opts[$item]} "
		done <<< $($MENU -o multi -p 'Options?' none "${!opts[@]}")
		git.msg commit $opt
		;;
	select-patch)
		local item i

		i=0
		for item in $(cat $commits); do
			git.auto cherry-pick -s $item
			i=$((i + 1))
		done

		select.reset
		echo "$i commit(s) has been created."
		;;
	merge-pick)
		for item in $(cat $commits); do
			list+="$item "
		done &> $__N

		if [[ -z "$item" ]]; then
			echo "no commit has been selected"
			return 1
		fi

		if ! git.msg cherry-pick -n $list; then
			echo "merging cherry-pick has failed"
			return 2
		fi

		if git commit -e -m "$(printf "TITLE:\n\nMerged:\n"; git show -s --format='- %h: %s' $list)"; then
            select.reset
		fi
		;;
	reuse-msg)
		sha=$(sed -n '1p' $commits)

		if [[ -z "$sha" ]]; then
			echo "no commit has been selected"
			return 1
		fi

		if git commit -e -C $sha; then
			select.reset
		fi
		;;
	*)
		echo "unknown type $TYPE"
	esac
}

select.refresh() {
	local i t

	i=0
	rm -f $commits
	for t in $(git for-each-ref --format='%(refname):%(objectname)' ${PREFIX_SELECT}/); do
		commit=${t##*:}
		tag=${t%%:*}

		git update-ref -d $tag
		git update-ref ${PREFIX_SELECT}/$i $commit
		echo "$commit" >> $commits
		((i++))
	done
}

select.reset() {
	local item i

	i=0
	for item in $(git tag -l | grep -E ^select/[0-9]+$); do
		git update-ref -d $PREFIX_SELECT/$((i++))
	done
	rm -f $commits
	echo "select: $i tags has been removed"
}

# C= commit.add
select.add() {
	local file idx
	local commit

	commit="$C"
	file=$commits
	touch $file

	idx=$(wc -l $file | cut -d' ' -f 1)
	if ! cat $file | grep -q $commit; then
		TYPE=refs NAME="${PREFIX_SELECT}/$((idx++))" refs.create
		echo $commit >> $file
		echo "select: $commit"
	else
		echo "'$commit' has already been added."
	fi
}

info.clean() {
	echo "clean configurations"
	rm -f $infos
}

# C= BR= TAG= REF= FILE= OFILE= info.write
# config:
# commit=
# local_branch=
# local_tag=
# track_branch=
# track_tag=
# remote_branch=
# remote_tag=
# remote=
info.write() {
	local commit file
	local local_branch local_tag
	local remote remote_branch remote_tag
	local track_branch track_tag

	is_commit "$C" && commit="$C"
	is_tag "$TAG" && tag="$TAG"

	if [[ -n "$FILE" && "$FILE" != "$__N" ]]; then
		file="$FILE"
	else
		file="$OFILE"
	fi

	# tag and branch commit?
	#       tag: branch:'',   refname:tag,         tag:tag
	#  local br: branch:name, refname:name,        tag:''
	# remote br: branch:name, refname:origin/name, tag:''
	if [[ "$BR" == "$REF" ]]; then
		local_branch="$BR"
	elif [[ "$TAG" == "$REF" ]]; then
		local_tag="$TAG"
	elif [[ -n "${REF%%/$BR}" ]]; then
		remote_branch="$BR"
		remote="${REF%%/$BR}"
	elif [[ -n "${REF%%/$TAG}" ]]; then
		remote_tag="$TAG"
		remote="${REF%%/$TAG}"
	else
		msg.err "no matched pattern ($REF) for br:$BR or tag:$TAG"
	fi

	config.load "$infos"
	config.set commit "$commit"
	config.set local_branch "$local_branch"
	config.set local_tag "$local_tag"
	config.set remote_branch "$remote_branch"
	config.set remote_tag "$remote_tag"
	config.set remote "$remote"
	config.set track_branch "$track_branch"
	config.set track_tag "$track_tag"
	config.set file "$file"
	config.dump
	config.save
}

# Print context from the selected version, before blame maps it to an origin.
info.line_context() {
	local file=$1 line=$2
	printf 'Selected line in %s (line %s):\n' "$file" "$line"
	awk -v line="$line" 'NR >= line - 3 && NR <= line + 3 {
		printf "%s %6d  %s\n", NR == line ? ">" : " ", NR, $0
	}'
	printf '\n'
}

# VIEW= FILE= OLD_FILE= LINE= OLD_LINE= TEXT= REF= info.line_history
info.line_history() {
	local view=$VIEW file=$FILE old_file=$OLD_FILE line=$LINE old_line=$OLD_LINE text=$TEXT ref=$REF
	local contents='' temp='' blame commit origin filename

	if [[ $view == diff || $view == stage ]]; then
		case $text in
		-*) file=$old_file; line=$old_line ;;
		+*|' '*) ;;
		*) echo 'Select a line inside a diff hunk.' >&2; return 1 ;;
		esac
	fi
	if [[ -z $file || $file == /dev/null || ! $line =~ ^[1-9][0-9]*$ ]]; then
		echo 'No file and line available to trace.' >&2
		return 1
	fi

	if [[ $view == diff && $text == -* ]]; then
		ref="${ref}^"
	elif [[ $view == stage ]]; then
		case $ref in
		'Staged changes'*)
			if [[ $text == -* ]]; then
				ref=HEAD
			else
				temp=$(mktemp) || return 1
				git show ":$file" > "$temp" || { rm -f "$temp"; return 1; }
				contents=$temp
			fi
			;;
		'Unstaged changes'*)
			if [[ $text == -* ]]; then
				temp=$(mktemp) || return 1
				git show ":$file" > "$temp" || { rm -f "$temp"; return 1; }
				contents=$temp
			else
				contents="$topdir/$file"
			fi
			;;
		*) echo 'Cannot determine which version is shown in stage view.' >&2; return 1 ;;
		esac
		if [[ -n $contents ]]; then
			info.line_context "$file" "$line" < "$contents"
			if ! git cat-file -e "HEAD:$file" 2>/dev/null; then
				[[ -z $temp ]] || rm -f "$temp"
				echo 'This file has no committed history at its current path.'
				return 0
			fi
			blame=$(git -c core.quotePath=false blame --line-porcelain --contents "$contents" -L "$line,$line" HEAD -- "$file")
			local result=$?
			[[ -z $temp ]] || rm -f "$temp"
			if (( result )); then return "$result"; fi
			read -r commit origin _ <<< "$blame"
			if [[ $commit =~ ^0+$ ]]; then
				echo 'This line has no committed origin.'
				return 0
			fi
			filename=${blame#*$'\n'filename }
			filename=${filename%%$'\n'*}
			if [[ $filename == \"*\" ]]; then
				filename=$(python3 -c 'import codecs, os, sys; sys.stdout.buffer.write(codecs.escape_decode(os.fsencode(sys.argv[1][1:-1]))[0])' "$filename") || return 1
			fi
			file=$filename
			line=$origin
			ref=$commit
			printf 'Tracing committed origin %s:%s at %s\n' "$file" "$line" "$ref"
		fi
	fi
	if [[ -z $contents ]]; then
		git show "${ref}:${file}" | info.line_context "$file" "$line"
	fi
	python3 "$(dirname -- "${BASH_SOURCE[0]}")/line-history-context.py" "$line" "$file" "$ref"
}

action.check() {
	local action

	if action=$(what_action); then
		printf "'%s' is in progress\n" "$action"
		return 1
	fi

	case $? in
		1)
			printf '%s\n' "not in any git session"
			;;
		2)
			printf '%s\n' "not inside a Git repository" >&2
			return 2
			;;
	esac
}

action.abort() {
	local action

	if (( $# )); then
		"$@" || return
	fi

	if action=$(what_action); then
		git.msg "$action" --abort
		return
	fi

	case $? in
		1)
			printf '%s\n' "No abortable Git operation found." >&2
			return 1
			;;
		2)
			printf '%s\n' "Not inside a Git repository." >&2
			return 2
			;;
	esac
}

action.next() {
	local action

	if (( $# )); then
		"$@" || return
	fi

	if action=$(what_action); then
		git.msg "$action" --continue
		return
	fi

	case $? in
		1)
			printf '%s\n' "No resumable Git operation found." >&2
			return 1
			;;
		2)
			printf '%s\n' "Not inside a Git repository." >&2
			return 2
			;;
	esac
}

commit_report() {
	cat <<-EOF
	-- Commit Report --

	$(printf -- "Commit\tAuthor\n")
	EOF
	git shortlog --summary --numbered --all --no-merges
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	# Named values may appear before or after the command; -- passes the rest through.
	cmd.dispatch() {
		local __tig_item __tig_literal=0
		local -a __tig_args=()

		for __tig_item in "$@"; do
			if (( __tig_literal )); then
				__tig_args+=("$__tig_item")
			elif [[ $__tig_item == -- ]]; then
				__tig_literal=1
				if (( ${#__tig_args[@]} )); then
					__tig_args+=("$__tig_item")
				fi
			elif [[ $__tig_item =~ ^[a-zA-Z_][a-zA-Z0-9_]*= ]]; then
				if [[ ${__tig_item%%=*} == __tig_* ]]; then
					echo 'Variable names beginning with __tig_ are reserved.' >&2
					return 1
				fi
				printf -v "${__tig_item%%=*}" '%s' "${__tig_item#*=}" || return
			else
				__tig_args+=("$__tig_item")
			fi
		done
		if (( ! ${#__tig_args[@]} )); then
			echo 'No command specified.' >&2
			return 1
		fi
		"${__tig_args[@]}"
	}
	cmd.dispatch "$@"
fi
