#!/usr/bin/env bash

# $0 link name list...
setup_version() {
    local link name list priority
    local timeout

    if [[ $# < 3 ]]; then
        show_err "at least 3 vars: '$@'"
        return $bad
    fi

    link=$1
    name=$2
    shift 2
    list=$@ # seperated by " "

    priority=101 # prevent conflict with other priority numbers
    for location in $list; do
        sudo update-alternatives --install $link $name $location $priority
        priority=$((priority + 100))
    done

    timeout=30
    echo "auto skip after $timeout secs"
    timeout $timeout sudo update-alternatives --config $name
}
