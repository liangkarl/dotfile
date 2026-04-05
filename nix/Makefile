XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=nix
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)mkdir -p "${CONFIG_DIR}"
	$(H)test -f "${CONFIG_DIR}/nix.conf" && echo "nix config ready: ${CONFIG_DIR}/nix.conf"

install:
	$(H)echo "-- $(PKG_NAME): install package manager --"
	$(H)if command -v nix >/dev/null 2>&1; then
		echo "nix already installed"
	else
		curl -L https://nixos.org/nix/install | sh -s -- --daemon
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove config --"
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
