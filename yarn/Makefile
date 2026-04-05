XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=yarn
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)ln -snf "${CONFIG_DIR}/yarnrc.yml" "${HOME}/.yarnrc.yml"

install:
	$(H)echo "-- $(PKG_NAME): install package manager --"
	$(H)if ! command -v node >/dev/null 2>&1; then
		echo "node is required; run make npm first"
		exit 1
	fi
	$(H)if command -v corepack >/dev/null 2>&1; then
		corepack enable
		corepack prepare yarn@stable --activate
	else
		npm install -g corepack
		corepack enable
		corepack prepare yarn@stable --activate
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove config --"
	$(H)rm -f "${HOME}/.yarnrc.yml"
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
