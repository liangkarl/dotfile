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
ACTION_TARGETS:=install uninstall config
PKGS:=$(filter-out $(ACTION_TARGETS),$(MAKECMDGOALS))

-include $(ROOT)/apps/Makefile

.ONESHELL:

all: $(LIST)

# dotfile: $(DOTFILE)

$(LIST):
	$(H)if [ -n "$(filter $(ACTION_TARGETS),$(MAKECMDGOALS))" ]; then
		exit 0
	fi
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

install:
	$(H)if [ -z "$(strip $(PKGS))" ]; then
		echo "Usage: make install [pkg1] [pkg2] ..."
		exit 1
	fi
	$(H)$(MAKE) --no-print-directory $(PKGS)

config:
	$(H)if [ -z "$(strip $(PKGS))" ]; then
		echo "Usage: make config [pkg1] [pkg2] ..."
		exit 1
	fi
	$(H)$(MAKE) --no-print-directory $(PKGS)

uninstall:
	$(H)if [ -z "$(strip $(PKGS))" ]; then
		echo "Usage: make uninstall [pkg1] [pkg2] ..."
		exit 1
	fi
	$(H)for pkg in $(PKGS); do
		H=$(H) $(MAKE) --no-print-directory $$pkg.remove || exit $$?
	done

ifneq (,$(filter $(ACTION_TARGETS),$(MAKECMDGOALS)))
%:
	@:
endif

.PHONY: all %.remove install uninstall config $(LIST) $(ALIAS) bin
