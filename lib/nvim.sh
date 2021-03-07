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

nvim_install_nvim() {
    local SOURCE
    SOURCE=('stable_nvim' 'unstable_nvim')

    already_has_cmd $NVIM && return $?

	echo "Start installing $NVIM"

    for SRC in ${SOURCE[@]}; do
        install_from_${SRC}
        check_install_cmd $NVIM && return $?
        show_err "Install $NVIM from $SRC failed"
    done

    check_install_cmd $NVIM || return $?

    # Remove unnessary dependencies
	sudo apt autoremove -y
	# config_package
}

nvim_install_nvim_optional() {
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

nvim_install_plug_vim() {
	local -r URL='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs $URL
}

nvim_install_fzf() {
    local FZF

    FZF=fzf
    already_has_cmd $FZF && return $?

    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
}

nvim_config_nvim() {
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

	# for vista.nvim
    already_has_cmd catgs || {
        echo "install ctags for vista.nvim"
        apt_ins ctags
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
}

nvim_config_coc_plugin() {
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

    need_cmd $NVIM || return $?

    NOTICE=/tmp/tmp.words
    PACK="${NPM_PACKAGES[@]}"

    echo "Please exit nvim manually after coc plugins installed." > $NOTICE

    nvim +"CocInstall $PACK" $NOTICE
}

nvim_install() {
    local ARGS
    ARGS="$1"

    echo "Install $NVIM..."
    __take_action $NVIM install $ARGS
    return $?
}

nvim_remove() {
    local ARGS
    ARGS="$1"

	echo "Remove $NVIM..."
    __take_action $NVIM remove $ARGS
    return $?

	# Remove package itself without system configs
	# sudo apt remove $NVIM

	# Remove package itself & system config
	# sudo apt purge $NVIM

	# Remove related dependency
	# sudo apt autoremove
	# still remain user configs
}

nvim_config() {
    local ARGS
    ARGS="$1"

    echo "Configure $NVIM..."
    __take_action $NVIM config $ARGS
    return $?
}

nvim_list() {
    __show_list $NVIM $@
    return $?
}
