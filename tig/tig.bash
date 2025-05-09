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

dir='/tmp/tig'
NODE="${dir}/node"
patch_file=${dir}/tig.patch
info_file=${dir}/tig.save
p_opts='--binary --histogram'

mkdir $dir 2> $__N

cmd() { eval "$*"; }

cmd.msg() {
	if cmd $*; then
		echo "'$*' done"
	else
		echo "'$*' failed ($?)"
		false
	fi
}

git.msg() { cmd git $*; }

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

	if [[ -n "$change" ]] && act.check; then
		git stash pop stash@{0} || echo "failed to restore unchecked changes"
	fi
}

# is_commit <sha>
is_commit() { git rev-parse --verify --quiet ${1} &> $__N; }
# is_branch <branch>
is_branch() { git show-ref --verify --quiet refs/heads/${1} &> $__N; }
# is_tag <tag>
is_tag() { git show-ref --verify --quiet refs/tags/${1} &> $__N; }
# is_remote_branch <refname>
is_remote_branch() { git show-ref --verify --quiet refs/remotes/${1} &> $__N; }
# to_sha <tag|branch>
to_sha() { git rev-parse $1 2> $__N; }

# NAME=%(branch) [C=%(commit)] [TYPE=[local|remote]] br.check
br.check() {
	is_branch "$NAME"  || return 1

	is_commit "$C" || return 2

	[ "$(to_sha refs/heads/${NAME})" == "$(to_sha $C)" ]
}

# C=%(commit) br.get
br.get() {
	local br rev

	is_commit "$C" || return 1

	for br in $(git branch --format='%(refname:short)' | sed '/HEAD/d'); do
		rev=$(to_sha $br)
		if [[ "$rev" == "$C" ]]; then
			echo $br
			return
		fi
	done
	false
}

# br.add() {
#
# }
#
# tag.add() {
#
# }

# NAME=%(TAG) [C=%(commit)] [TYPE=[local|remote]] tag.check
tag.check() {
	is_tag "$NAME"  || return 1

	is_commit "$C" || return 2

	[ "$(to_sha refs/tags/${NAME})" == "$(to_sha $C)" ]
}

# C=%(commit) tag.get
tag.get() {
	local tag rev

	is_commit "$C" || return 1

	for tag in $(git tag -l); do
		rev=$(to_sha $tag)
		if [[ "$rev" == "$C" ]]; then
			echo $tag
			return
		fi
	done
	false
}

# node = commit
# C= TYPE=[t|b] node.refs
refs.get() {
	local branch rev

	is_commit "$C" || return 1

	if [[ "$TYPE" == 't' ]]; then
		C=$C tag.get
	else
		C=$C br.get
	fi
}

# Check remote branch
# get_remote_branch <branch>
refs.upstream() {
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

# NAME= stash.save
stash.save() {
	local repo="$(basename $(git rev-parse --show-toplevel))"
	local sha="$(git rev-parse --short HEAD)"

	git.msg stash save ${NAME:-${repo}.${sha}}
}

# NAME= stash.pop
stash.pop() {
	# stage changes if exist
	git diff --quiet || git add -u

	git.msg stash pop stash@{0}

	# reset to release staged changes
	git reset
}

# add <commit>
# C= TYPE=[t|b] refs.paste
refs.paste() {
	config.load $NODE
	config.get BR BR
	config.get TAG TAG
	if [[ -n "$BR" ]]; then
		git branch "$BR" "$C"
	elif [[ -n "$TAG" ]]; then
		git tag "$TAG" "$C"
	else
		echo "no assigned tag or branch"
	fi
	rm $NODE
}

# C= refs.cut
# BR= TAG= refs.cut
refs.cut() {
	local br tag

	if [[ -z "$TAG" && -z "$BR" ]]; then
		is_commit "$C" || return 1

		BR=$(C=$C br.get)
		TAG=$(C=$C tag.get)
		if [[ -z "$TAG$BR" ]]; then
			echo "no branch or tag available"
			return 2
		fi
	fi

	config.load $NODE
	if [[ -n "$BR" ]]; then
		if C=$C NAME=$BR br.check; then
			git branch -D $BR
			config.set "BR" "$BR"
		else
			echo "invalid branch: $BR, $C"
		fi
	elif [[ -n "$TAG" ]]; then
		if C=$C NAME=$TAG tag.check; then
			git tag -d $TAG
			if [[ "$TAG" =~ patch\.[0-9]+ ]]; then
				sed -i -e "/${TAG}/d" $patch_file
				patch.refresh
				return
			fi
			config.set "TAG" "$TAG"
		else
			echo "invalid tag: $TAG, $C"
		fi
	fi
	config.save
}

# 1. Choose a local reference then push to remote
# refs: info.write (local)
# refs: TAG= BR= REF= OPT= refs.push
# 2. Choose a local commit, and then push
# main: info.write (local)
# refs: TAG= BR= REF= OPT= refs.push
# 3. Choose remote reference then select local commit
# refs: info.write (remote)
# main: C= refs.push
# 4. Push to upstream
refs.push() {
	config.load "$info_file"
	config.get remote_branch "$remote_branch"
	config.get remote_tag "$remote_tag"
	config.get track_branch "$track_branch"
	config.get track_tag "$track_tag"
	config.get file "$file"

	if [[ -n "$BR" || -n "$TAG" || -n "$REF" ]]; then
		config.get local_branch local_branch
		config.get local_tag local_tag
		config.get commit commit

		if [[ -n "${REF%%/$BR}" ]]; then
			remote="${REF%%/$BR}"
		elif [[ -n "${REF%%/$TAG}" ]]; then
			remote="${REF%%/$TAG}"
		fi

		if [[ -n "$local_branch" ]]; then
			git.msg push $OPT $remote ${local_branch}:${BR}
		elif [[ -n "$local_tag" ]]; then
			git.msg push $OPT $remote ${local_tag}:${TAG}
		elif [[ -n "$commit" ]]; then
			git.msg push $OPT $remote ${commit}:${BR:-$TAG}
		fi
	elif [[ -n "$C" ]]; then
		config.get remote_branch remote_branch
		config.get remote_tag remote_tag
		config.get remote remote

		if [[ -z "$remote" ]]; then
			echo "no remote name"; false
			return
		fi

		git.msg push $OPT $remote ${C}:${remote_branch:-$remote_tag}
	fi

	rm -rf $info_file
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

	echo -n "$@" | $cmd
	echo "copy '$@'"
}

# FILE= stage_file
# - if [file] is empty, stage all files
stage.file() {
	if git diff --cached --quiet $FILE; then
		git add ${FILE:--u}
	else
		git reset --quiet HEAD $FILE
	fi
}

patch.refresh() {
	local i t p

	i=0
	for t in $(git tag -l | grep ^patch. | sort); do
		p="patch.$i"
		((i++))

		if [[ $t == $p ]]; then
			continue
		fi

		git tag $p $(git rev-parse $t)
		git tag -d $t
	done
}

patch.reset() {
	local item i

	i=0
	for item in $(cat $patch_file); do
		git tag -d patch.$((i++))
	done
	rm -f $patch_file
}

# (commit) C= patch.create
# (diff)   C=000... NAME= patch.create
# [OPT=all] patch.create
patch.create() {
	if [[ -z "$C" ]]; then
		local item i

		i=100
		for item in $(cat $patch_file); do
			git format-patch --start-number $((i++)) -k $p_opts -1 -o git-patch $item
		done &> $__N

		patch.reset
		echo "$((i - 100)) patches has been created."
	elif [[ "$C" =~ ^0+$ ]]; then
		git.msg diff --output=${NAME}.diff $p_opts $FILE
	elif is_commit $C; then
		git.msg format-patch -k $p_opts -o git-patch -1 $C $FILE
	fi
}

# C= patch.add
patch.add() {
	local file idx
	local commit

	commit="$C"
	file=$patch_file
	touch $file

	idx=$(wc -l $file | cut -d' ' -f 1)
	if ! cat $file | grep -q $commit; then
		echo "select commit patch. ($commit)"
		git tag patch.${idx} $commit
		echo $commit >> $file
	else
		echo "same commit patch has been detected. ($commit)"
	fi
}

# TAG= BR= push.create
push.create() {
	source $info_file

	if [[ -z "$remote" ]]; then
		echo "no remote name"; false
		return
	fi

	if [[ -z "$1" ]]; then
		echo "Empty branch or tag name"; false
		return
	fi

	git.msg push $remote ${BR:-$TAG}

	rm -rf $info_file
}

info.clean() {
	echo "clean configurations"
	rm -f $info_file
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

	config.load "$info_file"
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

# C= OPT= act.rebase
act.rebase() {
	git.auto rebase $OPT $C
}

act.check() {
	declare -A list
	list=()
	list[REBASE_HEAD]='rebase'
	list[MERGE_HEAD]='merge'
	list[REVERT_HEAD]='revert'
	list[CHERRY_PICK_HEAD]='cherry-pick'
	list[BISECT_ANCESTORS_OK]='bisect'

	local cmd bis
	for cmd in REBASE_HEAD MERGE_HEAD REVERT_HEAD CHERRY_PICK_HEAD; do
		if git rev-parse --verify $cmd &> $__N; then
			msg.dbg "'${list[$cmd]}' is in progress"
			return 1
		fi
	done

	bis=$(git rev-parse --show-toplevel)/.git/BISECT_ANCESTORS_OK
	if [[ -e $bis ]]; then
		msg.dbg "'${list[$bis]}' is in progress"
		return 1
	fi

	msg.dbg "not in any git session"
}

act.abort() {
	local cmd bis

	eval "$ARGS"

	for cmd in REBASE_HEAD MERGE_HEAD REVERT_HEAD CHERRY_PICK_HEAD; do
		if git rev-parse --verify $cmd &> $__N; then
			cmd=${cmd%%_HEAD}
			cmd=${cmd//_/-}
			cmd=${cmd~~}
			git.msg $cmd --abort
			return
		fi
	done

	bis=$(git rev-parse --show-toplevel)/.git/BISECT_START
	if [[ -e $bis ]]; then
		git.msg bisect reset
	fi
}

act.going() {
	local cmd

	eval "$*"
	for cmd in REBASE_HEAD MERGE_HEAD REVERT_HEAD CHERRY_PICK_HEAD; do
		if git rev-parse --verify $cmd &> $__N; then
			cmd=${cmd%%_HEAD}
			cmd=${cmd//_/-}
			cmd=${cmd~~}
			git.msg $cmd --continue
			return
		fi
	done
}

commit_report() {
	cat <<-EOF
	-- Commit Report --

	$(printf -- "Commit\tAuthor\n")
	EOF
	git shortlog --summary --numbered --all --no-merges
}

if [[ ! "$0" =~ git* ]]; then
	# Since tig request the format "BINARY FUNC xxx" and doesn't accept this
	# format "C=xxx BINARY FUNC", the solution here is define our custom
	# format "BINARY FUNC C=xxx"
	eval "$*"
fi

set -x
