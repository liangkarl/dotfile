XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=kitty
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"

install:
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)if command -v kitty >/dev/null 2>&1; then
		echo "kitty already installed"
	elif [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew install --cask kitty
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get update
		sudo apt-get install -y kitty
	else
		echo "Unsupported OS: $(OSTYPE)"
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package/config --"
	$(H)if [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew uninstall --cask kitty || true
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get remove -y kitty || true
	fi
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
