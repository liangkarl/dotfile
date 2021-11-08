#!/bin/bash

error() {
    echo $@ >&2
}

verify() {
    local patch_dir zip origin
    origin=$1
    patch_dir=$2
    zip=$3

    echo "clean $patch_dir in all projects"
    repo forall -c 'rm -rf '$patch_dir''
    tar -xvf $zip
    repo forall -pvc 'git am -sk --ignore-whitespace '${patch_dir}'/* 2>&-'

    local ans cmd

    read -p "everything fine? [Y/n] " ans
    if [[ "$ans" == 'n' ]]; then
        cmd='git am --abort 2>&-;'
        read -p "back to previous patch? [Y/n] " ans
        if [[ "$ans" != 'n' ]];  then
            repo forall -c "$cmd"
            echo "complete"
            return 0
        fi
    fi

    read -p "reset/clean to original HEAD? [Y/n] " ans
    if [[ "$ans" != 'n' ]]; then
        cmd+="git reset --hard $origin; rm -r $patch_dir"
    fi
    repo forall -c "$cmd"
    return 0
}

gen_patch() {
    local git repo tar
    git=$(which git)
    repo=$(which repo)
    tar=$(which tar)

    if (( $# == 0 )); then
        error "no valid input variables"
        declare -f $FUNCNAME
        return 2
    fi

    if [[ "$git" == "" ]] || [[ "$repo" == "" ]] || [[ "$tar" == "" ]]; then
        error "make sure that you've installed git, repo or tar"
        return 1
    fi

    local from target rev_range

    if (( $# == 2 )); then
        from="$1"
        target="$2"
    elif (( $# == 1 )); then
        from='__begin'
        target="$1"
    fi

    local cmd

    echo "generate patch from $from to $target ..."
    if [[ "$from" == '__begin' ]]; then
        echo "set tag to HEAD for temp"
        cmd="git tag ${from}"
    fi
    cmd+="git format-patch --binary -k -o $target ${from}..${target};"
    cmd+="rmdir $target 2>&-"
    repo forall -pvc "$cmd"

    local name

    name=${target}_patchset.bz2
    echo "compress patch files, $name ..."
    repo list | awk '{print $1"/'${target}'"}'| xargs tar -cjf $name 2>&-

    if [[ "$from" == '__begin' ]]; then
        echo "remove tmp tag"
        repo forall -c "git tag -d ${from} 2>&-"
    fi

    name=${from,,}.xml
    repo manifest -r -o "$name"

    echo "complete"

    verify $from $target ${target}_patchset.bz2

    return 0
}

gen_patch $@
