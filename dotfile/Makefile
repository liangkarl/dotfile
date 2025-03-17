XDG_CONFIG_HOME?=${HOME}/.config
XDG_DATA_HOME?=${HOME}/.local/share
XDG_CACHE_HOME?=${HOME}/.cache
CONF_HOME:=${XDG_CONFIG_HOME}
DOTFILE_DIR:= $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
DOTFILE:=$(shell ls -p $(DOTFILE_DIR) | grep -v -E '/$|^\.|^Makefile')
UNDER_HOME:=clang-format editorconfig
UNDER_CONFDIR:=curlrc

.ONESHELL:

# There are two kinds of single configuration
# 1. copy to $HOME/.xxx
# 2. copy to $CONF_HOME/yyy
#
# Add the configuration file name to the targets
$(UNDER_HOME):
	$(H)cp -rvf $(DOTFILE_DIR)/$@ $(HOME)/.$@
	$(H)printf -- "-- completed: $@ --\n"

$(UNDER_CONFDIR):
	$(H)cp -rvf $(DOTFILE_DIR)/$@ $(CONF_HOME)/$@
	$(H)printf -- "-- completed: $@ --\n"

dotfile: $(DOTFILE)

.PHONY: $(DOTFILE) dotfile
