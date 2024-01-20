#!/usr/bin/env bash
# git installer script

usage() {
    echo "$(basename $0) [apt | github]"
}

github_install() {
    # https://github.com/git/git.git
    local url='https://github.com/git/git.git'
    local pos="/tmp/install/git"

    # remove install dir
    trap "rm -rf $pos" EXIT ERR

    # download git
    git clone --depth=1 $url $pos

    # need packages
    sudo apt install autoconf gettext asciidoc
    sudo apt install libcurl4-openssl-dev
    sudo apt autoremove

    # build git
    cd $pos
    make configure
    ./configure
    make
    sudo make install install-doc install-html
    cd -
}

apt_install() {
    sudo apt install git
}

trap 'pr_err "operation failed ($?)"' ERR
set -eE

bin='git'

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
