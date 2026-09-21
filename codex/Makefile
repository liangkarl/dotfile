PKG_NAME   := codex
CONFIG_DIR := ${XDG_CONFIG_HOME}/$(PKG_NAME)
MK_PATH    := $(abspath $(lastword $(MAKEFILE_LIST)))
MK_DIR     := $(shell dirname $(MK_PATH))

.ONESHELL:
config: # Run in $(CONFIG_DIR)
	ln -sf ${CONFIG_DIR} ${HOME}/.codex

install:
	$(H)echo "-- $(PKG_NAME): install package --"

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package --"
	# rm -rf $(MK_DIR)

.PHONY: config install uninstall
