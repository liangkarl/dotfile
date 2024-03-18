#!/usr/bin/env bash

git='git'
dir='/tmp/tig'
t=${dir}/tig.tag
b=${dir}/tig.branch

mkdir $dir 2>&-

_cmd() {
    local cmd="$1"; shift
    local opt="$@"
    local ret

    $git $cmd $opt > /dev/null
    ret=$?
    if (( $? == 0 )); then
        echo "'$cmd $opt' done"
    else
        echo "'$cmd $opt' failed ($?)"
		return $?
    fi
}

# cmd [git commands ...]
cmd() { _cmd $@; }
# cmd_abort [git commands ...]
cmd.rcv() { _cmd $@ || $git $1 --abort; }

stash() {
	local repo="$(basename $(git rev-parse --show-toplevel))"
	local sha="$(git rev-parse --short HEAD)"
	cmd stash save ${repo}.${sha}
	# git stash save "${repo}.${sha}"
}

# add [commit]
add() {
	if [[ -f $b ]]; then
		git branch $(cat $b) $1
	elif [[ -f $t ]]; then
		git tag $(cat $t) $1
	else
		echo "no assigned tag or branch"
	fi
	rm $t $b
}

del() {
	local tag="$1"
	local branch="$2"
	if [[ -n "$tag" ]]; then
		git tag -d $tag
		echo $tag > $t
	else
		git branch -D $branch
		echo "$branch" > $b
	fi
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

patch.reset() {
	local file="${dir}/tig.patch"
	local item i

	i=100
	for item in $(cat $file); do
		git tag -d patch.$((i - 100))
		(( i++ ))
	done
	rm -f $file
}

patch.create() {
	local file="${dir}/tig.patch"
	local item i

	if [[ ! -f $file ]]; then
		echo "no patch is selected"
		return
	fi

	i=100
	for item in $(cat $file); do
		git format-patch --start-number $i -k --binary --histogram -1 -o . $item
		git tag -d patch.$((i - 100))
		(( i++ ))
	done &> /dev/null
	rm -f $file
	echo "$((i - 100)) patches has been created."
}

ref.push() {
	:;
}

ref.pull() {
	:;
}

save() { :; }

# aim [config] [type]
aim() {
	local config="$1"
	local file idx
	local commit branch

	case $config in
		patch)
			commit="$2"
			file=${dir}/tig.patch
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
		push | fetch)
			remote="$2"
			branch="$3"
			file=${dir}/tig.branch
			touch $file

			echo "local remote=$remote" > $file
			echo "local branch=$branch" >> $file
			echo "set target branch: $remote, $branch"
			;;
		merge | rebase)
			;;
		filter)
			;;
	esac
}

# WA for the empty input to del()
if [[ $1 == 'del' ]]; then
	del "$2" "$3"
else
	$@
fi
