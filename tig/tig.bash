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
# to_sha <tag|branch>
to_sha() { git rev-parse $1 2> $__N; }

# FILE=%(file) C=%(commit) file.checkout
file.checkout() {
    true
}

# NAME= delete
delete() {
	name=$NAME
	target=$(while [[ "$name" != '.' ]]; do
		echo "$name"
		name=$(dirname $name)
	done | fzf --prompt='Delete Target: ')

	if [[ -z "$target" ]]; then
		echo "no file selected"
		return 1
	fi

	rm -ivr $target
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
		prompt='Select Tag:'
		;;
	branch)
		rev=${PREFIX_BR}
		prompt='Select Branch:'
		;;
	all)
		rev="${PREFIX_BR} ${PREFIX_TAG}"
		prompt='Select Ref:'
		;;
	*)
		echo "unsupport type $TYPE" >&2
		return 2
	esac

	list="$(git for-each-ref --points-at $C $rev --format='%(refname)')"
	count=$(printf "${list:+${list}\n}" | wc -l)
	if [[ $count -gt 1 ]]; then
		printf "$list" | fzf --prompt="$prompt"
	else
		echo $list
	fi
}

# C= refs.paste
refs.paste() {
	config.load $node
	config.get REFS REFS
	if [[ -n "$REFS" ]]; then
		git update-ref $REFS $C
	fi
	rm $node
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

	echo "Reference: $REFS"
	read -p "Rename To: " NAME
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
		git update-ref $NAME $C
	else
		git branch -m "${REFS##${PREFIX_BR}}" "$NAME"
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

	if [[ $? -eq 0 ]]; then
		rm -rf $infos
	fi
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
		echo "$((i - 100)) patch(es) has been created."
		;;
	*)
		echo "unknown type $TYPE"
	esac
}

# TYPE=merge-pick commit.create
# TYPE=reuse-msg  commit.create
commit.create() {
	local item list

	case "$TYPE" in
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
		git update-ref $PREFIX_SELECT/$((idx++)) $commit
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
        git log -S "$CURRENT_CONTENT" --date=short -- "$FILE"
    else
        # 如果有指定 SHA，則走原本的精確行號模式
        git log -L "${LINE},${LINE}:${FILE}" "$REV" --date=short
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
