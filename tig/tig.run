#!/usr/bin/env bash

git='git'
dir='/tmp/tig'
t=${dir}/tig.tag
b=${dir}/tig.branch
p=${dir}/tig.patch
m=${dir}/tig.commit
OUT=/dev/null

mkdir $dir 2>&-

_cmd() {
    local cmd="$1"; shift
    local opt="$@"
    local ret

    $git $cmd $opt > $OUT; ret=$?
    if (( $ret == 0 )); then
        echo "'$cmd $opt' done"
    else
        echo "'$cmd $opt' failed ($ret)"
		if [[ "$OUT" != "/dev/null" && -e "$OUT" ]]; then
			rm $OUT
		fi
		return $ret
    fi
}

# cmd [git commands ...]
cmd() { _cmd $@; }
# cmd_abort [git commands ...]
cmd.rcv() { _cmd $@ || $git $1 --abort; }

cmd.out() {
	OUT="$1"; shift
	_cmd $@
}

# Convert SHA to branch
# 1. giving both SHA and branch would return the branch name on the SHA
# 2. giving SHA would return any branch name on the SHA
# _to_branch <sha> [branch]
_to_branch() {
	local branch rev

	if [[ -n "$2" ]]; then
		rev=$(git rev-parse $2 2>&- || echo "")
		if [[ "$1" == "$rev" ]]; then
			echo $2
		else
			false
		fi
		return
	fi

	for branch in $(git branch --format='%(refname:short)'); do
		rev=$(git rev-parse $branch)
		if [[ "$rev" == "$1" ]]; then
			echo $branch
			return
		fi
	done

	false
}

# Check remote branch
# _to_branch <branch>
_to_remote_branch() {
	local remote

	if ! git show-ref --verify --quiet refs/heads/${1}; then
		return
	fi

	remote=$(git rev-parse --abbrev-ref ${1}@{upstream} 2>/dev/null)

	if [ -n "$remote" ]; then
		echo $remote
	fi
}

# Convert SHA to tag
# 1. giving both SHA and tag would return the tag name on the SHA
# 2. giving SHA would return any tag name on the SHA
# _to_tag <sha> [tag]
_to_tag() {
	local tag rev

	if [[ -n "$2" ]]; then
		rev=$(git rev-parse $2 2>&- || echo "")
		if [[ "$1" == "$rev" ]]; then
			echo $2
		else
			false
		fi
		return
	fi

	for tag in $(git tag -l); do
		rev=$(git rev-parse $tag)
		if [[ "$rev" == "$1" ]]; then
			echo $tag
			return
		fi
	done

	false
}

# To know which is the last action
# rebase/merge/am/revert/cherry-pick
_load_last_action() {
	local cmd
}

stash() {
	local repo="$(basename $(git rev-parse --show-toplevel))"
	local sha="$(git rev-parse --short HEAD)"
	cmd stash save ${repo}.${sha}
	# git stash save "${repo}.${sha}"
}

# add <commit>
add() {
	if [[ -f $b ]]; then
		source $b
		git branch $branch $1
	elif [[ -f $t ]]; then
		source $t
		git tag $tag $1
	else
		echo "no assigned tag or branch"
	fi
	rm $t $b
}

# del <commit>
del() {
	local tag=$(_to_tag $1)
	local branch=$(_to_branch $1)

	if [[ -n "$tag" ]]; then
		git tag -d $tag
		if [[ "$tag" =~ patch\.[0-9]+ ]]; then
			sed -i -e "/${1}/d" $p
			patch.refresh
			return
		fi
		echo "local tag=$tag" > $t
	else
		git branch -D $branch
		echo "local branch=$branch" > $b
	fi
}

# copy <text>
copy() {
	local cmd
	if type -f xclip > /dev/null; then
		cmd="xclip"
	elif type -f pbcopy > /dev/null; then
		cmd="pbcopy"
	else
		echo "no valid copy tools"; false
		return
	fi 2>&-

	echo -n "$@" | $cmd
	echo "copy '$@'"
}

# stage_file [file]
# - if [file] is empty, stage all files
stage_file() {
	if git diff --cached --quiet $1; then
		git add ${1:--u}
	else
		git reset --quiet HEAD $1
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
	local file="$p"
	local item i

	i=100
	for item in $(cat $file); do
		git tag -d patch.$((i - 100))
		(( i++ ))
	done
	rm -f $file
}

patch.create() {
	local file="$p"
	local item i

	i=100
	for item in $(cat $file); do
		git format-patch --start-number $i -k --binary --histogram -1 -o . $item
		git tag -d patch.$((i - 100))
		(( i++ ))
	done &> /dev/null

	rm -f $file
	echo "$((i - 100)) patches has been created."
}

# ref.push <commit>
ref.push() {
	source $b

	if [[ -z "$remote" ]]; then
		echo "no remote name"
	fi

	cmd push $remote ${1}:${branch}
	:;
}

# save "<commit>" "<branch>" "<refname>" "<tag>" "<file>"
save() {
	local save=${dir}/tig.save
	local mg co br rm tg fl

	if [[ "$1" =~ ^0+$ ]]; then
		co=
		br=
	else
		if [[ $(git cat-file -p $2 | grep -c '^parent ') > 1 ]]; then
			# it's a merge commit
			mg=y
		fi
		co=$1
		br=$(_to_branch $1 $2)
	fi

	# remote
	for str in $(git remote show); do
		if [[ "$3" != "${3#$str\/}" ]]; then
			rm=$str
			break
		fi
	done

	tg=$4

	# check file
	if [[ -e "$5" ]]; then
		fl=$5
	fi

	cat | tee $save <<-EOF
	# This is $([[ -z $mg ]] && echo "not") merged commit
	merge=$mg

	# $([[ "$1" =~ ^0+$ ]] && echo "un")committed
	commit=$co

	# ${2:-<null>}: branch is $([[ -z "$(_to_branch $1 $2)" ]] || echo "in")correct
	branch=$br

	# ${3:-<null>}: remote is $([[ -n "$(_to_remote_branch $br)" ]] || echo "non-")existed
	remote=$rm

	# ${4:-<null>}: tag is $([[ -z "$(_to_tag $1 $4)" ]] || echo "non-")existed
	tag=$tg

	# ${5:-<null>}: file is $([[ -e "$5" ]] || echo "non-")existed
	file=$fl
	EOF
}

clean() {
	echo "clean choose config"
	rm -f $save
}

# choose [config] [type]
choose() {
	local config="$1"; shift
	local file idx src
	local commit branch

	case $config in
		# patch <commit>
		patch)
			commit="$1"
			file=$p
			touch $file

			idx=$(wc -l $file | cut -d' ' -f 1)
			if ! cat $file | grep -q $commit; then
				echo "select commit patch. ($commit)"
				git tag patch.${idx} $commit
				echo $commit >> $file
			else
				echo "same commit patch has been detected. ($commit)"
			fi
			;;
		# remote <commit> <refname>
		push | pull)
			source $b 2>&- || touch $b

			if [[ -z "$remote" ]]; then
				remote="${2%%/*}"
				branch="${2#*/}"

				echo "local remote=$remote" >> $b
				echo "local branch=$branch" >> $b
				echo "set remote: $remote, $branch"
			else
				cmd.rcv $config $remote ${1}:${branch}
				rm $b
			fi
			;;
		# merge/rebase <commit> <branch>
		merge | rebase)
			source $m 2>&- || touch $m

			if [[ -z "$dst" ]]; then
				echo "set dst=$2"
				echo "local dst=$2" >> $m
			else
				cmd.rcv $config $dst $1
				rm $m
			fi
			;;
		clean)
			echo "clean choose config"
			rm -f $m $b
			;;
	esac
}

# WA for the empty input to del()
if [[ $1 == 'del' ]]; then
	del "$2" "$3"
else
	$@
fi
