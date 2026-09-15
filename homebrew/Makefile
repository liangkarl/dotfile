XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=homebrew
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
CONFIG_KEY=__HOMEBREW_INCLUDED__
BREW=$(shell command -v brew)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)if ! grep -q ${CONFIG_KEY} ${XDG_CONFIG_HOME}/bash/external.bash; then
		echo "### ${CONFIG_KEY} ###"
		echo "source ${CONFIG_DIR}/brew.env"
		echo ""
	fi >> ${XDG_CONFIG_HOME}/bash/external.bash

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
