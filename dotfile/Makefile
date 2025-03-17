XDG_CONFIG_HOME?=${HOME}/.config
XDG_DATA_HOME?=${HOME}/.local/share
XDG_CACHE_HOME?=${HOME}/.cache
CONF_HOME:=${XDG_CONFIG_HOME}
DOTFILE_DIR:= $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
DOTFILE:=$(shell ls -p $(DOTFILE_DIR) | grep -v -E '/$|^\.|^Makefile')

.ONESHELL:

$(DOTFILE):
	$(H)cp -rvf $(DOTFILE_DIR)/$@ $(HOME)/.$@
	$(H)printf -- "-- completed: $@ --\n"

dotfile: $(DOTFILE)

.PHONY: $(DOTFILE) dotfile
