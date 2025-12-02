XDG_CONFIG_HOME?=${HOME}/.config
XDG_DATA_HOME?=${HOME}/.local/share
XDG_CACHE_HOME?=${HOME}/.cache
CONF_HOME:=${XDG_CONFIG_HOME}
DOTFILE_DIR:= $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
DOTFILE:=$(shell ls -p $(DOTFILE_DIR) | grep -v -E '/$|^\.|^Makefile')
UNDER_HOME:=clang-format editorconfig quiltrc
UNDER_CONFDIR:=curlrc
UNDER_CONFDIR_SUBDIR:=

# copy_to_subdir subdir_name dofile_file
define copy_to_subdir
	mkdir -p $(CONF_HOME)/$(1)
	cp -rvf $(DOTFILE_DIR)/$(2) $(CONF_HOME)/$(1)/$(2)
endef

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
	$(H)cp -rvf $(DOTFILE_DIR)/$@ $(HOME)/.$@
	$(H)printf -- "-- completed: $@ --\n"

$(UNDER_CONFDIR):
	$(H)cp -rvf $(DOTFILE_DIR)/$@ $(CONF_HOME)/$@
	$(H)printf -- "-- completed: $@ --\n"

toprc:
	$(H)$(call copy_to_subdir,procps,$@)
	$(H)printf -- "-- completed: $@ --\n"

dotfile: $(DOTFILE)

.PHONY: $(DOTFILE) dotfile
