# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_CONFIG_HOME?=${HOME}/.config
XDG_DATA_HOME?=${HOME}/.local/share
XDG_CACHE_HOME?=${HOME}/.cache
TOP:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CONF_HOME:=${XDG_CONFIG_HOME}
SHELL?=bash

H?=@

LIST:=$(shell ls -d -- */ | sed 's:/::' | grep -v '^misc\|^dotfile')
DOTFILE:=$(shell ls -p dotfile/ | grep -v -E '/$|^\.|^Makefile' | sed 's/\.[^.]*$$//')

ALIAS:=top curl

.ONESHELL:

$(DOTFILE) dotfile:

$(LIST):
	$(H)$(eval SRC_DIR:=$(TOP)/$@)
	$(H)$(eval DST_DIR:=$(CONF_HOME)/$@)

	$(H)printf -- "-- $@: copy files --\n"
	$(H)cp -rvf $(SRC_DIR) $(CONF_HOME)/
	$(H)if [[ -e $(DST_DIR)/Makefile ]]; then
		H=$(H) make -C $(DST_DIR)
	elif [[ -e $(DST_DIR)/configure.sh ]]; then
		eval $(DST_DIR)/configure.sh
	fi
	$(H)printf -- "-- $@: completed --\n\n"

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
