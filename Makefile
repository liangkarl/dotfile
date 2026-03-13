# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_CONFIG_HOME?=${HOME}/.config
XDG_DATA_HOME?=${HOME}/.local/share
XDG_CACHE_HOME?=${HOME}/.cache
XDG_LOCAL_BIN ?=$(HOME)/.local/bin
ROOT     :=$(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
CONF_HOME:=${XDG_CONFIG_HOME}
SHELL?=bash

H?=@

LIST:=$(shell ls -d -- */ | sed 's:/::' | grep -v '^sys\|^apps\|^bin')

-include $(ROOT)/apps/Makefile

.ONESHELL:

all: $(LIST)

# dotfile: $(DOTFILE)

$(LIST):
	$(H)$(eval SRC_DIR:=$(ROOT)/$@)
	$(H)$(eval DST_DIR:=$(CONF_HOME)/$@)

	$(H)cp -rvf $(SRC_DIR) $(CONF_HOME)/
	$(H)if [ -e $(DST_DIR)/Makefile ]; then
		H=$(H) make -C $(DST_DIR)
	elif [ -e $(DST_DIR)/configure.sh ]; then
		eval $(DST_DIR)/configure.sh
	fi
	$(H)printf -- "-- completed: $@ --\n\n"

bin:
	$(H)mkdir -p $(XDG_LOCAL_BIN)
	$(H)cp -rvf $(ROOT)/bin/* $(XDG_LOCAL_BIN)

%.remove:
	$(H)$(eval NAME:=$(strip $(subst .remove,,$@)))
	$(H)if [ -d "$(CONF_HOME)/$(NAME)" ]; then
		rm -rvf $(CONF_HOME)/$(NAME)
	elif [ -e "$(CONF_HOME)/dotfile/$(NAME)" ]; then
		rm -rvf $(CONF_HOME)/dotfile/$(NAME)
		rm -rvf ~/.$(NAME)
	fi
	$(H)echo "Remove Configuration: $(NAME)"

%.install:

%.uninstall:

.PHONY: all %.remove %.install %.uninstall $(LIST) $(ALIAS) bin
