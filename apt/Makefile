XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=apt
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)echo "APT uses system-level config under /etc/apt; keep user notes in ${CONFIG_DIR}."

install:
	$(H)echo "-- $(PKG_NAME): check package manager --"
	$(H)if [[ "$(OSTYPE)" != "Linux" ]]; then
		echo "apt is only available on Linux"
		exit 0
	fi
	$(H)sudo apt-get update

uninstall:
	$(H)echo "-- $(PKG_NAME): remove config --"
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
