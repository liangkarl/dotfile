#!/usr/bin/env bash
# nvim installer script

usage() {
    echo "$(basename $0) [apt | github]"
}

prepare_plugin() {
    local url config_dir
    local pos

    # install vim-plug
    config_dir="${XDG_CONFIG_HOME:-$HOME/.local/share}"
    url='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    curl -fLo ${config_dir}/nvim/site/autoload/plug.vim --create-dirs $url

    # install fzf
    url='https://github.com/junegunn/fzf.git'
    pos="${config_dir}/fzf"
    git clone --depth=1 $url $pos
    eval ${pos}/install

    nvim +PlugInstall +qa
}

setup_default_editor() {
    local nvim

    nvim="$(type -p ${bin})"
    sudo update-alternatives --install /usr/bin/vi vi ${nvim} 400
    sudo update-alternatives --config vi
    sudo update-alternatives --install /usr/bin/vim vim ${nvim} 400
    sudo update-alternatives --config vim
    sudo update-alternatives --install /usr/bin/editor editor ${nvim} 400
    sudo update-alternatives --config editor
}

github_install() {
    # URL: https://github.com/neovim/neovim
    local url='https://github.com/neovim/neovim'
    local pos="/tmp/install/${bin}"
    local ans

    # add prerequisites modules
    sudo apt install ninja-build gettext libtool libtool-bin autoconf \
                    automake cmake g++ pkg-config unzip curl

    # remove install dir
    trap "rm -rf $pos" ERR EXIT

    # download git
    git clone --depth=1 $url $pos

    # build nvim
    ## choose version
    cd $pos
    PS3='Choose an install version: '
    select ver in 'stable' 'nightly'; do
        if [[ "$ver" == 'stable' ]]; then
            git checkout stable
        fi
        break
    done

    ## build nvim
    make -j4
    sudo make install
    cd -
}

apt_install() {
    local ver

    # choose version and add related ppa key
    select ver in 'stable' 'unstable' 'apt-preload'; do
        case $ver in
            stable)
                key='ppa:neovim-ppa/stable'
                trap "sudo add-apt-repository --remove ${ppa}" ERR

                echo 'add ppa key of stable nvim'
                sudo add-apt-repository $key
                sudo apt update
                ;;
            unstable)
                key='ppa:neovim-ppa/unstable'
                trap "sudo add-apt-repository --remove ${ppa}" ERR

                echo 'add ppa key of unstable nvim'
                sudo add-apt-repository $key
                sudo apt update
                ;;
            apt-preload)
                echo 'use default neovim package in apt list'
        esac
        break
    done

    # add prerequisites modules
    # NOTE: assume Linux distro is Ubuntu
    ver="$(lsb_release -r | awk '{print $2}')"
    if (( $ver >= 18.04 )); then
        sudo apt install python-neovim
        sudo apt install python3-neovim
    else
        sudo apt install python-dev python-pip python3-dev
        sudo apt install python3-setuptools
        sudo easy_install3 pip
    fi

    # install neovim
    sudo apt install neovim
}

trap 'pr_err "operation failed ($?)"' ERR
set -eE

bin='nvim'

if [[ ! -z "$(type -p ${bin})" ]]; then
    pr_warn "you have install ${bin} already"
fi

if [[ ! -z "$1" ]]; then
    if [[ -z "$(type ${1})_install" ]]; then
        usage
        exit 2
    fi

    eval ${1}_install
    exit 0
fi

PS3='select install source > '
select src in 'github' 'apt' 'skip' 'cancel'; do
    case $src in
        cancel)
            echo "cancel operation"
            exit 0
	    ;;
        skip)
            echo "skip installization"
            ;;
        *)
            eval ${src}_install
    esac
    break
done

# check if install plugin or not
ans=''
read -p "do you want to install prerequisites of plugins? (Y/n) " ans
if [[ "${ans,,}" != 'n' ]]; then
    prepare_plugin
fi

# check if setup default editor or not
read -p "do you want to setup default editor? (Y/n) " ans
if [[ "${ans,,}" != 'n' ]]; then
    setup_default_editor
fi

pr_good "install complete: ${bin}"
