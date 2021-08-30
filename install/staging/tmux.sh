#!/bin/bash
# tmux installer script

usage() {
    echo "$(basename $0) [apt | github]"
}

github_install() {
    # URL: https://github.com/tmux/tmux
    local url='https://github.com/tmux/tmux.git'
    local pos="/tmp/install/tmux"

    # NOTE: need packages
    # autoconf, automake, pkconf, libevent-dev
    sudo apt install autoconf automake pkg-config libevent-dev
    sudo apt autoremove

    # remove install dir
    trap "rm -rf $pos" EXIT ERR

    # download git
    git clone --depth=1 $url $pos

    # build tmux
    cd $pos
    sh autogen.sh
    ./configure
    make
    sudo make install
    cd -
}

apt_install() {
    sudo apt install $bin
}

trap 'pr_err "operation failed ($?)"' ERR
set -eE

bin='tmux'
if [[ ! -z "$(type -p $bin)" ]]; then
    pr_warn "you have install $bin already"
fi

if [[ ! -z "$1" ]]; then
    if [[ -z "$(type ${1}_install)" ]]; then
        usage
        exit 2
    fi

    eval ${1}_install
    exit 0
fi

PS3='select install source > '
select src in 'github' 'apt' 'cancel'; do
    case $src in
        cancel)
            exit 0;;
        *)
            eval ${src}_install
    esac
    break
done

pr_good "install complete: $bin"
