#!/bin/bash

source $CORE_DIR/utils.sh
# source $CORE_DIR/sign.sh

NVIM_NAME='nvim'
NVIM_CONFIG="$CONFIG_DIR/$NVIM_NAME"
APT_PACKAGES="
	'python3-pip'
	'npm'
"

# cpplint is used to check c/cpp format
PIP3_PACKAGES="
	pynvim
	cpplint
"

NPM_PACKAGES="
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

install()
{
	if test_cmd $NVIM_NAME; then
		echo "$NVIM_NAME is already installed"
	else
		echo "Start installing $NVIM_NAME"
		sudo add-apt-repository ppa:neovim-ppa/stable
		sudo apt update -y
		sudo apt install -y 'neovim'
		sudo apt autoremove -y
		config_package
	fi
}

uninstall()
{
	echo "Remove $NVIM_NAME..."
}

config_package()
{
	echo "Config $NVIM_NAME..."

	# link config
	local -r NVIM_DIR=$HOME/.config/nvim
	if [ -d $NVIM_DIR ]; then
		rm -rf $NVIM_DIR.bak
		mkdir $NVIM_DIR.bak
		mv $NVIM_DIR/* $NVIM_DIR.bak
	else
		mkdir $NVIM_DIR
	fi
	ln -s $NVIM_CONFIG $NVIM_DIR

	# Install Plug-vim
	local -r URL='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs $URL
	nvim +PlugInstall +qa

	# check external commands for plugin
	# ag, ripgrep
	# snap install ripgrep
	# sudo apt install silversearcher-ag
	# config_plugin
}

config_plugin()
{
	# Install plugins with vim-plug
	nvim +PlugInstall +qa

	local -r EXT_DIR="$HOME/.config/coc/extensions"
	# Install
	# Install extensions
	mkdir -p $EXT_DIR
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
