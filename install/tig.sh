#!/usr/bin/env bash
# tig installer script

usage() {
    echo "$(basename $0) [apt | github]"
}

github_install() {
    # https://github.com/jonas/tig.git
    local url='https://github.com/jonas/tig.git'
    local pos="/tmp/install/tig"

    # remove install dir
    trap "rm -rf $pos" EXIT ERR

    # download tig
    git clone --depth=1 $url $pos

    # need packages
    sudo apt install autoconf asciidoc ncurses-dev
    sudo apt autoremove

    # build tig
    cd $pos
    make configure
    ./configure
    make
    sudo make install
    cd -
}

apt_install() {
    sudo apt install tig
}

trap 'pr_err "operation failed ($?)"' ERR
set -eE

bin='tig'

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
