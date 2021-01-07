#!/bin/bash

source $CORE_DIR/utils.sh
# source $CORE_DIR/sign.sh

NVIM_NAME='nvim'
NVIM_CONFIG="$CONFIG_DIR/$NVIM_NAME"
USR_CONFIG="$HOME/.config"
APT_PACKAGES="
	'python3-pip'
	'npm'
"

# cpplint is used to check c/cpp format
PIP3_PACKAGES="
	pynvim
	cpplint
"

# prepared binary:
# curl, npm
NEED_PACKAGES="
    curl
    npm
"
need_packages()
{
    for package in $NEED_PACKAGES; do
        if ! test_cmd package; then
            echo $package
        fi
    done
}

install()
{
	if test_cmd $NVIM_NAME; then
		echo "$NVIM_NAME is already installed"
		return
	fi

        local NEED=need_packages
        if [ -z $NEED ]; then
            echo "Need to install: $NEED" >&2
            return
        fi

	echo "Start installing $NVIM_NAME"
	sudo add-apt-repository ppa:neovim-ppa/stable
	sudo apt update

	sudo apt install -y neovim

	if test_cmd nvim; then
		sudo apt install python-neovim
		sudo apt install python3-neovim
	else
		sudo add-apt-repository ppa:neovim-ppa/unstable
		sudo apt update
		sudo apt install -y neovim
		sudo apt install python-dev python-pip python3-dev python3-pip
	fi

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
	local -r NVIM_DIR="$USR_CONFIG/$NVIM"
	[ -e $NVIM_DIR ] || return

	create_link $NVIM_CONFIG $USR_CONFIG

	# Install Plug-vim
	local -r URL='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs $URL

	# for vista.nvim
	sudo apt install -y ctags

	# Prepare for coc.nvim
	## Update nodejs with ppa
	sudo apt install curl
	curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
	sudo apt install nodejs

	# Start install plugin for nvim
	nvim +PlugInstall +qa

	sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
	sudo update-alternatives --config vi
	sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
	sudo update-alternatives --config vim
	sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
	sudo update-alternatives --config editor
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

	# Change extension names to the extensions you need
	npm install $NPM_PACKAGES \
		--global-style --ignore-scripts \
		--no-bin-links --no-package-lock \
		--only=prod
	popd
}
