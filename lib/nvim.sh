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

install()
{
	if has_cmd $NVIM_NAME; then
		echo "$NVIM_NAME is already installed"
		return
	fi

	echo "Start installing $NVIM_NAME"

    add_ppa_repo ppa:neovim-ppa/stable
    install_if_no nvim neovim

	if ! has_cmd nvim; then
        add_ppa_repo ppa:neovim-ppa/unstable
        install_if_no nvim neovim
    fi

    sudo apt install python-neovim
    sudo apt install python3-neovim
    sudo apt install python-dev python-pip python3-dev python3-pip

	sudo apt autoremove -y
	config_package
}

uninstall()
{
	echo "Remove $NVIM_NAME..."
}

config_package()
{
	echo "Config $NVIM_NAME..."

	# link config
	local -r NVIM_DIR="$USR_CONFIG_DIR/$NVIM"
	[ -e $NVIM_DIR ] || return

	create_link $NVIM_DIR $USR_CONFIG_DIR
	create_link $NVIM_DIR/editorconfig $HOME/.editorconfig
	create_link $NVIM_DIR/clang-format.txt $HOME/.clang-format

	# Install Plug-vim
	local -r URL='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    install_if_no curl
	curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs $URL

	# for vista.nvim
    install_if_no ctags
	sudo apt install -y ctags

	# Prepare for coc.nvim
	## Update nodejs with ppa
	curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
	sudo apt install nodejs

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
		coc-json
		coc-python
		coc-vimlsp
		coc-sh
		coc-markdownlint
		coc-xml
		coc-highlight
		coc-yank
		coc-lists
		coc-explorer
	"

	local -r EXT_DIR="$HOME/.config/coc/extensions"

	[ -e $EXT_DIR ] || mkdir -p $EXT_DIR

	# Install coc extensions
	pushd $EXT_DIR
	[[ ! -f package.json ]] &&
		echo '{"dependencies":{}}'> package.json

    install_if_no npm
	# Change extension names to the extensions you need
	npm install $NPM_PACKAGES \
		--global-style --ignore-scripts \
		--no-bin-links --no-package-lock \
		--only=prod
	popd
}
