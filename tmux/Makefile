PKG_NAME=tmux
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
MK_PATH    := $(abspath $(lastword $(MAKEFILE_LIST)))
MK_DIR     := $(shell dirname $(MK_PATH))

.ONESHELL:
config: # Run in $(CONFIG_DIR)
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)cp -v tmux.entry ~/.local/bin

install:
	$(H)echo "-- $(PKG_NAME): install package --"

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package --"


.PHONY: config install uninstall
