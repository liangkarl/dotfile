PKG_NAME=tmux
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
MK_PATH    := $(abspath $(lastword $(MAKEFILE_LIST)))
MK_DIR     := $(shell dirname $(MK_PATH))

.ONESHELL:
config.$(PKG_NAME): # Run in $(CONFIG_DIR)
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)cp -v tmux.entry ~/.local/bin

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install package --"

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove package --"

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
