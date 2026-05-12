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
p_opts='--binary --histogram'
patchdir=${topdir}/git-patch

heads=(
	REBASE_HEAD
	MERGE_HEAD
	REVERT_HEAD
	CHERRY_PICK_HEAD
	BISECT_START
)

declare -A opts
opts=(
	[REBASE_HEAD]='rebase'
	[MERGE_HEAD]='merge'
	[REVERT_HEAD]='revert'
	[CHERRY_PICK_HEAD]='cherry-pick'
	[BISECT_START]='bisect'
)

mkdir $tmpdir 2> $__N

show_cmd() {
	if $*; then
		echo "'$*' done"
	else
		echo "'$*' failed ($?)"
		false
	fi
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

# FILE=%(file) C=%(commit) file.checkout
file.checkout() {
    true
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

# NAME= stash.save
stash.save() {
	local repo="$(basename $topdir)"
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

# TAG=|BR= C= [TYPE=[local|remote]] refs.verify
refs.verify() {
	is_commit "$C" || return 1

    if [[ -n "$TAG" ]] && is_tag "$TAG"; then
        [ "$(to_sha refs/tags/${TAG})" == "$(to_sha $C)" ]
        return $?
    elif [[ -n "$BR" ]] && is_branch "$BR"; then
        [ "$(to_sha refs/heads/${BR})" == "$(to_sha $C)" ]
        return $?
    fi

    return 3
}

# C= [TAG=y] [BR=y] UP= refs.find
refs.find() {
	local tag br rev

	is_commit "$C" || return 1

    if [[ -n "$TAG" ]]; then
        for tag in $(git tag -l); do
            rev=$(to_sha $tag)
            if [[ "$rev" == "$C" ]]; then
                echo $tag
                return
            fi
        done
    elif [[ -n "$BR" ]]; then
        for br in $(git branch --format='%(refname:short)' | sed '/HEAD/d'); do
            rev=$(to_sha $br)
            if [[ "$rev" == "$C" ]]; then
                echo $br
                return
            fi
        done
    fi

    return 2
}

# add <commit>
# C= TYPE=[t|b] refs.paste
refs.paste() {
	config.load $node
	config.get BR BR
	config.get TAG TAG
	if [[ -n "$BR" ]]; then
		git branch "$BR" "$C"
	elif [[ -n "$TAG" ]]; then
		git tag "$TAG" "$C"
	else
		echo "no assigned tag or branch"
	fi
	rm $node
}

# C= NAME= [BR=] [TAG=] refs.rename
refs.rename() {
	set -x
	is_commit "$C" || return 1
	if [[ -n "$BR" ]] && refs.verify; then
        git branch -m "$BR" "$NAME"
	elif [[ -n "$TAG" ]] && refs.verify; then
        git tag -d "$TAG"
        git tag "$NAME" "$C"
	else
        echo "Invalid inputs: C($C) NAME($NAME) TAG($TAG) BR($BR)"
	fi
}

# C= [BR=] [TAG=] [REMOTE=] refs.cut
# TODO: add cutting remove branchs & tags
refs.cut() {
	local br tag

	if [[ -z "$TAG" && -z "$BR" ]]; then
		is_commit "$C" || return 1

		TAG=$(C=$C TAG=y BR='' refs.find)
		BR=$(C=$C BR=y TAG='' refs.find)
		if [[ -z "$TAG$BR" ]]; then
			echo "no branch or tag available"
			return 2
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
	elif [[ -n "$BR" ]]; then
		if C=$C BR=$BR refs.verify; then
			git branch -D $BR
			config.set "BR" "$BR"
		else
			echo "invalid branch: $BR, $C"
		fi
	elif [[ -n "$TAG" ]]; then
		if C=$C TAG=$TAG refs.verify; then
			git tag -d $TAG
			if [[ "$TAG" =~ patch\.[0-9]+ ]]; then
				sed -i -e "/${TAG}/d" $commits
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
# refs: (local)  info.write C= BR= REF= TAG= FILE= OFILE=
# refs: (remote) refs.push TAG= BR= REF=
#
# 2. Choose a local commit, and then push
# main: (local)  info.write C= FILE= OFILE=
# refs: (remote) refs.push TAG= BR= REF=
#
# 3. Choose remote reference then select local commit
# refs: (remote) info.write C= BR= REF= TAG= FILE= OFILE=
# main: (local)  refs.push C=
#
# 4. Create a new branch
# main: (local 1)  info.write C= FILE= OFILE=
# refs: (local 2)  info.write C= BR= REF= TAG= FILE= OFILE=
# refs: (remote) refs.push REMOTE= [BR= TAG=]
#
# 5. Push to upstream
# refs: (local) refs.push UPSTREAM= BR= TAG=
refs.push() {
	local cmd

	config.load "$infos"
	config.get remote_branch "$remote_branch"
	config.get remote_tag "$remote_tag"
	config.get track_branch "$track_branch"
	config.get track_tag "$track_tag"
	config.get file "$file"

	# 4. Create a new branch
	if [[ -n "$REMOTE" ]]; then
		config.get local_branch local_branch
		config.get local_tag local_tag

		TAG=${TAG:-$local_tag}
		BR=${BR:-$local_branch}

		if [[ -n "${local_branch}${local_tag}" ]]; then
			cmd="git.msg push $OPT $REMOTE ${local_branch}${local_tag}"
			if [[ -n "${BR}${TAG}" ]]; then
				cmd+=":$TAG$BR"
			fi
		fi
		eval "$cmd"

	elif [[ -n "$UPSTREAM" ]]; then
		git.msg push

	# 1. Choose a local reference, and then push to remote
	# 2. Choose a local commit, and then push to remote
	elif [[ -n "$BR$TAG$REF" ]]; then
		config.get local_branch local_branch
		config.get local_tag local_tag
		config.get commit commit

		if [[ -n "${REF%%/$BR}" ]]; then
			remote="${REF%%/$BR}"
		elif [[ -n "${REF%%/$TAG}" ]]; then
			remote="${REF%%/$TAG}"
		fi

		if [[ -n "${local_branch}${local_tag}" ]]; then
			git.msg push $OPT $remote ${local_branch}${local_tag}:${BR}${TAG}
		elif [[ -n "$commit" ]]; then
			git.msg push $OPT $remote ${commit}:${BR}${TAG}
		fi

	# 3. Choose remote reference then select local commit
	elif [[ -n "$C" ]]; then
		config.get remote_branch remote_branch
		config.get remote_tag remote_tag
		config.get remote remote

		if [[ -z "$remote" ]]; then
			echo "no remote name"; false
			return
		fi

		git.msg push $OPT $remote ${C}:${remote_branch}${remote_tag}

	fi

	rm -rf $infos
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

# FILE= stage_file
# - if [file] is empty, stage all files
stage.file() {
	if git diff --cached --quiet $FILE; then
		git add ${FILE:--u}
	else
		git reset --quiet HEAD $FILE
	fi
}

# (stash)  TYPE=stash        C=stash@{x} [FILE=] patch.create
# (diff)   TYPE=new-patch    C=[000..|xxx] [FILE=] patch.create
# (select) TYPE=select-patch patch.create
patch.create() {
	[[ ! -d "$patchdir" ]] && mkdir ${patchdir}

	out=${patchdir}/${NAME:-$(date +%y%m%d-%H%M%S)}${FILE:+_$(basename $FILE)}
	case "$TYPE" in
	new-patch)
		echo "output: ${out}.patch"
		if [[ "$C" =~ ^0+$ ]]; then
			git diff $p_opts ${FILE+-- $FILE} | tee ${out}.patch
		elif is_commit $C; then
			git diff $p_opts ${C}^ ${C} ${FILE+-- $FILE} | tee ${out}.patch
		fi
		;;
	stash)
		echo "output: ${out}.patch"
		git diff $p_opts ${C}^1 ${C} ${FILE+-- $FILE} | tee ${out}.patch
		;;
	select-patch)
		local item i

		i=100
		for item in $(cat $commits); do
			git format-patch --start-number $((i++)) -k $p_opts -1 -o ${patchdir} $item
		done &> $__N

		select.reset
		echo "$((i - 100)) patches has been created."
		;;
	*)
		echo "unknown type $TYPE"
	esac
}

# C= commit.create
commit.create() {
	local item list

	for item in $(cat $commits); do
		list+="$item "
	done &> $__N

	git.msg cherry-pick -n $list
	git commit -e -m "$(printf "TITLE:\n\nMerged:\n"; git show -s --format='- %h: %s' $list)"
	select.reset
}

select.refresh() {
	local i t p

	i=0
	for t in $(git tag -l | grep ^select. | sort); do
		p="select.$i"
		((i++))

		if [[ $t == $p ]]; then
			continue
		fi

		git tag $p $(git rev-parse $t)
		git tag -d $t
	done
}

select.reset() {
	local item i

	i=0
	for item in $(git tag -l | grep -E ^select\.[0-9]+$); do
		git tag -d select.$((i++))
	done
	rm -f $commits
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
		echo "select: $commit"
		git tag select.${idx} $commit
		echo $commit >> $file
	else
		echo "'$commit' has already been added."
	fi
}

# TAG= BR= push.create
push.create() {
	source $infos

	if [[ -z "$remote" ]]; then
		echo "no remote name"; false
		return
	fi

	if [[ -z "$1" ]]; then
		echo "Empty branch or tag name"; false
		return
	fi

	git.msg push $remote ${BR:-$TAG}

	rm -rf $infos
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

# FILE= LINE= REV= info.line_history
info.line_history() {
	if [ -z "$FILE" ] || [ -z "$LINE" ]; then
		echo "Usage: $0 <file_path> <line_number>"
		exit 1
	fi

    # Step 1: 從特定版本提取該行的內容（用於搜尋第一次出現的 commit）
    # 使用 git show 確保我們拿到的是該版本的內容
    # local LINE=$(git show "${REV}:${FILE}" | sed -n "${LINE}p")

    # if [ -z "$LINE" ]; then
    #     echo "Error: Could not find line $LINE in $FILE at revision $REV"
    #     return 1
    # fi

	# 如果使用者沒有指定 SHA，代表他可能想查目前正在改的這一行
    if [ -z "$REV" ]; then
        # 取得目前工作目錄該行的內容
        local CURRENT_CONTENT=$(sed -n "${LINE}p" "$FILE")
        echo "Checking history for current (unstaged) content:"
		echo "\"$CURRENT_CONTENT\""

        # 從 HEAD 開始往回找這行內容
        git log -S "$CURRENT_CONTENT" --pretty=format:"%h %an %ad %s" --date=short -- "$FILE"
    else
        # 如果有指定 SHA，則走原本的精確行號模式
        git log -L "${LINE},${LINE}:${FILE}" "$REV" --pretty=format:"%h %an %ad %s" --date=short
    fi
}

action.check() {
	local hdr bis

	bis=${gitdir}/BISECT_START
	echo "gitdir: ${gitdir}"
	if [[ -e $bis ]]; then
		echo "'${opts[$bis]}' is in progress"
		return 1
	fi

	for hdr in "${heads[@]}"; do
		if git rev-parse --verify $hdr &> $__N; then
			echo "'${opts[$hdr]}' is in progress"
			return 1
		fi
	done
	echo "not in any git session"
}

action.abort() {
	local hdr bis

	eval "$ARGS"

	bis=${gitdir}/BISECT_START
	if [[ -e $bis ]]; then
		git.msg bisect reset
		return
	fi

	for hdr in "${heads[@]}"; do
		if git rev-parse --verify $hdr &> $__N; then
			git.msg ${opts[$hdr]} --abort
			return
		fi
	done
}

action.next() {
	local hdr

	eval "$*"
	for hdr in "${heads[@]}"; do
		if git rev-parse --verify $hdr &> $__N; then
			git.msg ${opts[$hdr]} --continue
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
	# As tig requests the format "script FUNC argv1 ..." and doesn't accept this
	# format "C=xxx script FUNC", so we could define our custom format
	# "script FUNC C=xxx"
	eval "$*"
fi
