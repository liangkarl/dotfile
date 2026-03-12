XDG_CONFIG_HOME?=${HOME}/.config
XDG_DATA_HOME?=${HOME}/.local/share
XDG_CACHE_HOME?=${HOME}/.cache
CONF_HOME:=${XDG_CONFIG_HOME}
DOTFILE_DIR:=$(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
DOTFILE_HOMEDIR=$(DOTFILE_DIR)/home
DOTFILE_CONFDIR=$(DOTFILE_DIR)/config
UNDER_HOME:=$(shell ls -p $(DOTFILE_HOMEDIR))
UNDER_CONFDIR:=$(shell ls -p $(DOTFILE_CONFDIR))
DOTFILE:=$(UNDER_HOME) $(UNDER_CONFDIR)
UNDER_CONFDIR_SUBDIR:=

.ONESHELL:

# There are two kinds of single configuration
# 1. copy file xxx to $HOME/.xxx
#  - Follow $(UNDER_HOME) rule
# 2. copy file yyy to $CONF_HOME/yyy
#  - Follow $(UNDER_CONFDIR) rule
# 3. copy file zzz to $CONF_HOME/zzz/zzz
#  - Follow manual rules
# 4. copy file ooo to $CONF_HOME/ooo/aaa
#  - Follow manual rules
#
# Add the configuration file name to the targets
$(UNDER_HOME):
	$(H)cp -rvf $(DOTFILE_HOMEDIR)/$@ $(HOME)/.$@
	$(H)printf -- "-- completed: $@ --\n"

$(UNDER_CONFDIR):
	$(H)cp -rvf $(DOTFILE_CONFDIR)/$@ $(CONF_HOME)/$@
	$(H)printf -- "-- completed: $@ --\n"

dotfile: $(DOTFILE)

.PHONY: $(DOTFILE) dotfile
