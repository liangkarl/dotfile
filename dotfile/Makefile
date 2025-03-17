XDG_CONFIG_HOME?=${HOME}/.config
XDG_DATA_HOME?=${HOME}/.local/share
XDG_CACHE_HOME?=${HOME}/.cache
CONF_HOME:=${XDG_CONFIG_HOME}
MK_PATH    := $(abspath $(lastword $(MAKEFILE_LIST)))
TOP        := $(shell dirname $(MK_PATH))
MK_DIR     := $(TOP)
#DOTFILE:=$(shell ls -p $(MK_DIR) | grep -v -E '/$|^\.|^Makefile' | sed 's/\.[^.]*$$//')
DOTFILE:=$(shell ls -p $(MK_DIR) | grep -v -E '/$|^\.|^Makefile')

.ONESHELL:

$(DOTFILE):
	$(H)cp -rvf $(MK_DIR)/$@ $(HOME)/.$@
	$(H)printf -- "-- completed: $@ --\n"

dotfile: $(DOTFILE)

.PHONY: $(DOTFILE) dotfile
