#!/bin/bash

source $SHELL_CORE_DIR/core.sh
source $SHELL_CORE_DIR/installer.sh

NVIM='nvim'
NVIM_DIR="$SHELL_CONFIG_DIR/$NVIM"

# cpplint is used to check c/cpp format
PIP3_PACKAGES="
	pynvim
	cpplint
"

install_from_stable_nvim() {
    add_ppa_repo ppa:neovim-ppa/stable
    apt_ins neovim
}

install_from_unstable_nvim() {
    add_ppa_repo ppa:neovim-ppa/unstable
    apt_ins neovim
}

install() {
    local SOURCE
    SOURCE=('stable_nvim' 'unstable_nvim')

    has_cmd $NVIM && {
        show_hint "$(info_installed $NVIM)"
        return
    }

	echo "Start installing $NVIM"

    for SRC in ${SOURCE[@]}; do
        install_from_${SRC}
        has_cmd $NVIM && {
            show_good "Install $NVIM successfully"
            break
        }
        show_err "Install $NVIM from $SRC failed"
    done

    has_cmd $NVIM || {
        show_err "No way to install $NVIM"
        return
    }

    # Remove unnessary dependencies
	sudo apt autoremove -y
	config_package
}

install_nvim_optional() {
    local PACK
    need_cmd pip2 pip3 && {
        PACK='pynvim'
        pip2 show $PACK >&- || pip2 install $PACK
        pip3 show $PACK >&- || pip3_ins $PACK

        PACK='neovim-remote'
        pip3 show $PACK >&- || pip3_ins $PACK
    }

    need_cmd npm && {
        npm_ins_g neovim
    }
}

install_plug_vim() {
	local -r URL='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs $URL
}

install_fzf() {
    local FZF

    FZF=fzf
    has_cmd $FZF && {
        show_hint "$(info_installed $FZF)"
        return
    }

    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
}

config_package() {
	echo "Config $NVIM..."
    need_cmd curl git pip3 pip || return $?

	# link config
	[ -e $HOME_CONFIG_DIR ] || mkdir $HOME_CONFIG_DIR

    goto $HOME_CONFIG_DIR
    link $NVIM_DIR .
    back

    goto $HOME
	link $NVIM_DIR/editorconfig .editorconfig
	link $NVIM_DIR/clang-format.txt .clang-format
    back

    install_plug_vim

    install_fzf

	# for vista.nvim
    has_cmd ctags || {
        echo "install ctags for vista.nvim"
        sudo apt install -y ctags
    }

    # for float term
    pip install neovim-remote || {
        show_err "install 'neovim-remote' failed from pip install"
    }

	# Start install plugin for nvim
	nvim +PlugInstall +qa

    sudo npm install -g neovim

	setup_version "/usr/bin/vi" "vi" "/usr/bin/nvim"
	setup_version "/usr/bin/vim" "vim" "/usr/bin/nvim"
	setup_version "/usr/bin/editor" "editor" "/usr/bin/nvim"
	# check external commands for plugin
	# ag, ripgrep
	# snap install ripgrep
	# sudo apt install silversearcher-ag
	config_coc_plugin
}

config_coc_plugin() {
	local PACK NPM_PACKAGES EXT_DIR
    local NOTICE

    NPM_PACKAGES=(
        "coc-html"
        "coc-xml"
        "coc-json"
        "coc-pyright"
        "coc-vimlsp"
        "coc-sh"
        "coc-markdownlint"
        "coc-highlight"
        "coc-yank"
        "coc-lists"
        "coc-explorer"
    )

    has_cmd nvim || {
        show_err "$(info_req_cmd nvim)"
        return 1
    }

    NOTICE=/tmp/tmp.words
    PACK="${NPM_PACKAGES[@]}"

    echo "Please exit nvim manually after coc plugins installed." > $NOTICE

    nvim +"CocInstall $PACK" $NOTICE
}
