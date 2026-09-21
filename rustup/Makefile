XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=npm
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"

install:
	$(H)echo "-- $(PKG_NAME): install package manager --"
	$(H)brew install rustup

uninstall:
	$(H)echo "-- $(PKG_NAME): remove config --"
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
