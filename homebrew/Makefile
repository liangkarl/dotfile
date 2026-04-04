XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=homebrew
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
BREW=$(shell command -v brew)

.ONESHELL:

config.$(PKG_NAME): install.$(PKG_NAME)
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)if [[ -f "${CONFIG_DIR}/brew.env" ]]; then
		grep -q 'homebrew/brew.env' "${HOME}/.bashrc" || echo '[[ -f "${CONFIG_DIR}/brew.env" ]] && source "${CONFIG_DIR}/brew.env"' >> "${HOME}/.bashrc"
	fi

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install package manager --"
	$(H)if [[ -z "$(BREW)" ]]; then
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	else
		echo "brew already installed: $(BREW)"
	fi

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove config --"
	$(H)rm -rf "${CONFIG_DIR}"

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
