XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=zsh
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"

install:
	$(H)echo "-- $(PKG_NAME): install shell --"
	$(H)if command -v zsh >/dev/null 2>&1; then
		echo "zsh already installed"
	elif [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew install zsh
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get update
		sudo apt-get install -y zsh
	else
		echo "Unsupported OS: $(OSTYPE)"
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package/config --"
	$(H)if [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew uninstall zsh || true
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get remove -y zsh || true
	fi
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
