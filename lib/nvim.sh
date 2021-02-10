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
    sudo apt update
    sudo apt install neovim
}

install_from_unstable_nvim() {
    add_ppa_repo ppa:neovim-ppa/unstable
    sudo apt update
    sudo apt install neovim
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
    local NEED_CMD PACK CHECK
    NEED_CMD='pip2 pip3'
    if has_cmd $NEED_CMD; then
        PACK='pynvim'
        pip2 show $PACK >&- || pip2 install $PACK
        pip3 show $PACK >&- || pip3 install $PACK

        PACK='neovim-remote'
        pip3 show $PACK >&- || pip3 install $PACK
    else
        show_warn "$(info_req_cmd $NEED_CMD)"
    fi

    NEED_CMD='npm'
    if has_cmd $NEED_CMD; then
        PACK='neovim'
        sudo npm install -g $PACK
    else
        show_warn "$(info_req_cmd $NEED_CMD)"
    fi
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
    local NEED_CMD
    NEED_CMD='curl git pip3 pip'

	echo "Config $NVIM..."
    has_cmd $NEED_CMD || {
        show_err "$(info_req_cmd $NEED_CMD)"
        return
    }

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
	local NPM_PACKAGES EXT_DIR
    NPM_PACKAGES="
		coc-html
		coc-xml
		coc-json
		coc-pyright
		coc-vimlsp
		coc-sh
		coc-markdownlint
		coc-highlight
		coc-yank
		coc-lists
		coc-explorer
	"
	EXT_DIR="$HOME/.config/coc/extensions"

    has_cmd npm || {
        show_err "$(info_req_cmd npm)"
        return
    }
    # install lsp server without coc plugin
    # sudo npm install -g bash-language-server
    # sudo npm install -g vim-language-server

	[ -e $EXT_DIR ] || mkdir -p $EXT_DIR

	# Install coc extensions
	goto $EXT_DIR
    [ ! -f package.json ] &&
		echo '{"dependencies":{}}'> package.json

	# Change extension names to the extensions you need
	npm install $NPM_PACKAGES \
		--global-style --ignore-scripts \
		--no-bin-links --no-package-lock \
		--only=prod
	back
}
