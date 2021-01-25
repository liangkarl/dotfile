#!/bin/bash

source $SHELL_CORE_DIR/utils.sh

NVIM_NAME='nvim'
NVIM_DIR="$SHELL_CONFIG_DIR/$NVIM_NAME"
APT_PACKAGES="
	'python3-pip'
	'npm'
"

# cpplint is used to check c/cpp format
PIP3_PACKAGES="
	pynvim
	cpplint
"

install_from_stable_nvim()
{
    add_ppa_repo ppa:neovim-ppa/stable
    sudo apt update
    sudo apt install neovim
}

install_from_unstable_nvim()
{
    add_ppa_repo ppa:neovim-ppa/unstable
    sudo apt update
    sudo apt install neovim
}

install()
{
	if has_cmd $NVIM_NAME; then
		echo "$NVIM_NAME is already installed"
		return
	fi

    local SOURCE=('stable_nvim' 'unstable_nvim')
	echo "Start installing $NVIM_NAME"

    for SRC in ${SOURCE[@]}; do
        install_from_${SRC}
        has_cmd $NVIM_NAME && {
            echo "Install $NVIM_NAME successfully"
            break
        }
        show_err "Install $NVIM_NAME from $SRC failed"
    done

    has_cmd nvim || {
        show_err "No way to install $NVIM_NAME"
        return
    }

    sudo apt install python-neovim
    sudo apt install python3-neovim
    sudo apt install python-dev python-pip python3-dev python3-pip

    # Remove unnessary dependencies
	sudo apt autoremove -y
	config_package
}

install_plug_vim()
{
	local -r URL='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs $URL
}

install_fzf()
{
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
}

config_package()
{
	echo "Config $NVIM_NAME..."

    local NEED_CMD='curl git npm'
    has_these_cmds || {
        show_err "Need these installization of $NEED_CMD"
        return
    }

	# link config
	local -r NVIM_DIR="$USR_CONFIG_DIR/$NVIM"
	[ -e $NVIM_DIR ] || return

	create_link $NVIM_DIR $USR_CONFIG_DIR
	create_link $NVIM_DIR/editorconfig $HOME/.editorconfig
	create_link $NVIM_DIR/clang-format.txt $HOME/.clang-format

    install_plug_vim

    install_fzf

	# for vista.nvim
    install_if_no ctags
	sudo apt install -y ctags

    # for float term
    install_if_no pip3 python3-pip
    install_if_no pip python-pip
    setup_version "/usr/bin/pip" "pip" "/usr/local/bin/pip /usr/local/bin/pip3"
    pip install neovim-remote

	# Start install plugin for nvim
	nvim +PlugInstall +qa

	setup_version "/usr/bin/vi" "vi" "/usr/bin/nvim"
	setup_version "/usr/bin/vim" "vim" "/usr/bin/nvim"
	setup_version "/usr/bin/editor" "editor" "/usr/bin/nvim"
	# check external commands for plugin
	# ag, ripgrep
	# snap install ripgrep
	# sudo apt install silversearcher-ag
	# config_plugin
}

config_coc_plugin()
{
	local -r NPM_PACKAGES="
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

	local -r EXT_DIR="$HOME/.config/coc/extensions"

    # for lsp server
    # sudo npm install -g bash-language-server
    # sudo npm install -g vim-language-server

	[ -e $EXT_DIR ] || mkdir -p $EXT_DIR

	# Install coc extensions
	pushd $EXT_DIR
	[[ ! -f package.json ]] &&
		echo '{"dependencies":{}}'> package.json

	# Change extension names to the extensions you need
	npm install $NPM_PACKAGES \
		--global-style --ignore-scripts \
		--no-bin-links --no-package-lock \
		--only=prod
	popd
}
