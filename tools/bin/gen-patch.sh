#!/usr/bin/env bash

usage() {
    local n

    n=$(basename $0)
    cat <<-EOF
    $n -s start
    $n -e end
    $n -a patch.zip
EOF

    exit $1
}

apply() {
    local tmp_cmd sha_list

    tmp_cmd=$(mktemp)
    sha_list=$(mktemp)

    cat > $tmp_cmd <<-EOF
    rev="$(git rev-parse HEAD)"
    echo "${rev},$(pwd)" >> $sha_list
    git am -sk --ignore-whitespace '${PATCH_OUT}'/*
    if (( $? != 0 )); then
        echo "recover working tree due to 'am' error. ($?)"
        git am --abort
        git reset --hard $rev
    fi
    EOF
    tar -xvf $1
    repo forall -pvc "bash $tmp_cmd"

    read -p "reset/clean to original HEAD? [Y/n] " ans
    [[ "${ans,,}" == n ]] && exit

    cat > $tmp_cmd <<-EOF
    rev="$(cat $sha_list | awk -F, '/'$(pwd)'/{print $1}')"
    echo "$(pwd),${rev}" >> $sha_list
    git reset --hard $rev
    rm -rf $PATCH_OUT
    EOF
    repo forall -pvc "bash $tmp_cmd"

    exit
}

PATCH_OUT='.patch'

(( $# == 0 )) && usage 1

while (( $# != 0 )); do
    case $1 in
        -s) shift
            from="$1"
            ;;
        -e) shift
            target="$1"
            ;;
        -a) shift
            afile="$1"
            ;;
        *)
            usage 2
            ;;
    esac
    shift
done

# exit script if verify enabled
[[ ! -z "$afile" ]] && apply $afile

[[ -z "$from" ]] && usage 3
[[ -z "$target" ]] && target='HEAD'

# TODO: check ${from} is available for this git or not
tmp_cmd=$(mktemp)
cat > $tmp_cmd <<-EOF
git format-patch --binary -k -o $PATCH_OUT ${from}..${target}
[[ -z "$(ls -A $PATCH_OUT)" ]] && rm -rf $PATCH_OUT
EOF

echo "generate patch from $from to $target ..."
repo forall -pvc "bash $tmp_cmd"

name=${target}_patchset.bz2
echo "compress patch files, $name ..."
repo list | awk '{print $1"/'$PATCH_OUT'"}'| xargs tar -cjf $name 2>&-
repo manifest -r -o "${from,,}.xml"

rm -rf $tmp_cmd
echo "complete"
