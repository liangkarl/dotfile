# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_CONFIG_HOME?=${HOME}/.config
XDG_DATA_HOME?=${HOME}/.local/share
XDG_CACHE_HOME?=${HOME}/.cache
MK_PATH    := $(abspath $(lastword $(MAKEFILE_LIST)))
TOP     := $(shell dirname $(MK_PATH))
# TOP:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CONF_HOME:=${XDG_CONFIG_HOME}
SHELL?=bash

H?=@

#DOTFILE:=$(shell ls -p $(TOP)/dotfile | grep -v -E '/$|^\.|^Makefile' | sed 's/\.[^.]*$$//')
DOTFILE:=$(shell ls -p $(TOP)/dotfile | grep -v -E '/$|^\.|^Makefile')
LIST:=$(shell ls -d -- */ | sed 's:/::' | grep -v '^misc\|^setup\|^dotfile')
ALIAS:=top curl

-include $(TOP)/dotfile/Makefile

.ONESHELL:

# dotfile: $(DOTFILE)

$(LIST):
	$(H)$(eval SRC_DIR:=$(TOP)/$@)
	$(H)$(eval DST_DIR:=$(CONF_HOME)/$@)

	$(H)cp -rvf $(SRC_DIR) $(CONF_HOME)/
	$(H)if [[ -e $(DST_DIR)/Makefile ]]; then
		H=$(H) make -C $(DST_DIR)
	elif [[ -e $(DST_DIR)/configure.sh ]]; then
		eval $(DST_DIR)/configure.sh
	fi
	$(H)printf -- "-- completed: $@ --\n\n"

top: procps

curl: curlrc

%.remove:
	$(H)$(eval NAME:=$(strip $(subst .remove,,$@)))
	$(H)if [[ -d "$(CONF_HOME)/$(NAME)" ]]; then
		rm -rv $(CONF_HOME)/$(NAME)
	elif [[ -e "$(CONF_HOME)/dotfile/$(NAME)" ]]; then
		rm -rv $(CONF_HOME)/dotfile/$(NAME)
		rm -rv ~/.$(NAME)
	fi
	$(H)echo "Remove Configuration: $(NAME)"

%.install:

%.uninstall:

.PHONY: all %.remove %.install %.uninstall $(LIST) $(ALIAS)
