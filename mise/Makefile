XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=mise
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
BREW=$(shell command -v brew)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"

install:
	$(H)echo "-- $(PKG_NAME): install package manager --"
	$(H)if [[ -z "$(BREW)" ]]; then
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	else
		echo "brew already installed: $(BREW)"
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove config --"
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
