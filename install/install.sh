#!/usr/bin/env bash

usage() {
    local name
    name=$(basename $0)

    cat <<-EOF
	$name [-h] [-al] [PACKAGE NAME...]
	-a: install all
	-l: install packages with menu selection
	-h: print help
	EOF

    return $1
}

install_all() {
    local i name packages

    # for test
    # search and source below dirs
    # read all packages from $LOCATION
    # LOCATION=([name]="path/to/script")

    # get index from $LOCATION
    packages=''

    i=0
    while [[ -n "${packages[$i]}" ]]; do
        name=${packages[$i]}
        install "$name" || {
            echo "install failed. ($?)"
            exit 4
        }
        ((i++))
    done

    echo "install all done."
}

install_list() {
    # search and source below dirs
    # read all packages from $PACKAGES

    # detect screen height

    # show menu
    ## show 'next' if the items are more than the height value

    # select options

    echo "select done."
}

install() {
    local file name
    name="$1"
    file=${LOCATION[$name]}

    [[ -e "$file" ]] && return 10

    cat <<-EOF
	================================
	install '$name'
	script '$file'
	================================
	EOF

    eval $file || return 20

    return 0
}

(( $# == 0 )) && usage 0

input=()

while (( $# > 0 )); do
    case $1 in
        -l | --list)
            install_list

            # clean vars
            input=()
            break
            ;;
        -a | --all)
            install_all

            # clean vars
            input=()
            exit 0
            ;;
        -h | --help)
            usage 0
            ;;
        -?* | --?*) # invaild string
            usage 2
            ;;
        *)  # no var
            input+=("$1")
    esac
    shift
done

# search and source below dirs
# read all packages from $PACKAGES

i=0
while [[ -n "${input[$i]}" ]]; do
    install ${input[i]} || {
        echo "install failed. ($?)"
        exit 3
    }
    ((i++))
done
