XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=pipx
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config.$(PKG_NAME): install.$(PKG_NAME)
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)pipx ensurepath

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install package manager --"
	$(H)if [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew install pipx
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get update
		sudo apt-get install -y pipx || sudo apt-get install -y python3-pipx
	else
		echo "Unsupported OS: $(OSTYPE)"
	fi

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove config --"
	$(H)rm -rf "${CONFIG_DIR}"

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
