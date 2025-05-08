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
patch=${dir}/tig.patch
save_conf=${dir}/tig.save

mkdir $dir 2> $__N

git.msg() {
	if git $*; then
		echo "'$*' done"
	else
		echo "'$*' failed ($?)"
		false
	fi
}

git.auto() {
	git.msg $* || git.msg $1 --abort
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
				sed -i -e "/${TAG}/d" $patch
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
	local file="$patch"
	local item i

	i=100
	for item in $(cat $file); do
		git tag -d patch.$((i - 100))
		(( i++ ))
	done
	rm -f $file
}

patch.create() {
	local file="$patch"
	local item i

	i=100
	for item in $(cat $file); do
		git format-patch --start-number $i -k --binary --histogram -1 -o . $item
		git tag -d patch.$((i - 100))
		(( i++ ))
	done &> $__N

	rm -f $file
	echo "$((i - 100)) patches has been created."
}

# C= patch.add
patch.add() {
	local file idx
	local commit

	commit="$C"
	file=$patch
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

# FORCE= C= push
push() {
	local dst args

	source $save_conf

	if [[ -z "$remote" ]]; then
		echo "no remote name"; false
		return
	fi

	if [[ -n "$branch" ]]; then
		dst="$branch"
	elif [[ -n "$tag" ]]; then
		dst="$tag"
	else
		echo "no remote branch or tag"; false
		return
	fi

	if [[ "$FORCE" == 'y' ]]; then
		args="--force-with-lease"
		shift
	fi

	git.msg push $args $remote ${C:-HEAD}:${dst}

	rm -rf $save_conf
}

# TAG= BR= push.create
push.create() {
	source $save_conf

	if [[ -z "$remote" ]]; then
		echo "no remote name"; false
		return
	fi

	if [[ -z "$1" ]]; then
		echo "Empty branch or tag name"; false
		return
	fi

	git.msg push $remote ${BR:-$TAG}

	rm -rf $save_conf
}

# SHA=
# BR=
# REF=
# TAG=
# FILE=

info.clean() {
	echo "clean configurations"
	rm -f $save_conf
}

# VAR=VAL info.write
# 1. select local br/tag
#  - SRC=xxx info.write
# 2. push to remote
#  - DST=xxx info.write; push
info.write() {
	local commit branch refname tag file
	local is_merged is_remote remote raw

	config.load $save_conf
	config.get is_merged "is_merged"
	config.get is_remote "is_remote"
	config.get commit "commit"
	config.get branch "branch"
	config.get remote "remote"
	config.get tag "tag"
	config.get file "file"
	config.get src "src"
	config.get dst "dst"

	commit="$C"
	branch="$NAME"
	refname="$REF"
	tag="$NAME"
	file="$FILE"

	src="$SRC"
	dst="$DST"

	if [[ "$commit" =~ ^0+$ ]]; then
		commit=
		branch=
		tag=
		refname=
	else
		if [[ $(git cat-file -p $commit | grep -c '^parent ') > 1 ]]; then
			is_merged=y
		fi

		# tag and branch commit?
		#       tag: branch:'',   refname:tag,         tag:tag
		#  local br: branch:name, refname:name,        tag:''
		# remote br: branch:name, refname:origin/name, tag:''
		if [[ "$branch" == "$refname" ]]; then
			remote=''
			branch=$(check_branch $commit $branch)
		else
			is_remote=y
			remote="${refname%/$branch}"
		fi

		tag=$(check_tag $commit $tag)
	fi

	# check file
	[[ -e "$FILE" ]] && file="$FILE"

	config.set "is_merged" "$is_merged"
	config.set "is_remote" "$is_remote"
	config.set "commit" "$commit"
	config.set "branch" "$branch"
	config.set "remote" "$remote"
	config.set "tag" "$tag"
	config.set "file" "$file"
	config.set "src" "$src"
	config.set "dst" "$dst"
	config.dump
	config.save
}

# C= OPT= act.rebase
act.rebase() {
	local change
	local stash

	change=$(git status --porcelain | grep -v '^??')
	if [[ -n "$change" ]]; then
		git stash
		stash=y
	fi

	git.msg rebase $OPT $C
	if [[ "$stash" == y  ]] && act.check; then
		git stash pop stash@{0}
	fi
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

	bis=$(git rev-parse --show-toplevel)/.git/BISECT_ANCESTORS_OK
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
