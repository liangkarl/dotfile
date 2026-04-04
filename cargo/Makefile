XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=cargo
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config.$(PKG_NAME): install.$(PKG_NAME)
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)mkdir -p "${HOME}/.cargo"
	$(H)ln -snf "${CONFIG_DIR}/config.toml" "${HOME}/.cargo/config.toml"

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install rust toolchain (cargo via rustup) --"
	$(H)if command -v cargo >/dev/null 2>&1; then
		echo "cargo already installed"
		exit 0
	fi
	$(H)if [[ "$(OSTYPE)" == "Darwin" ]]; then
		if command -v brew >/dev/null 2>&1; then
			brew install rustup-init
			rustup-init -y
		else
			curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		fi
	else
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	fi

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove config --"
	$(H)rm -f "${HOME}/.cargo/config.toml"
	$(H)rm -rf "${CONFIG_DIR}"

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
