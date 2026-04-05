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

install:
	$(H)if [ -z "$(strip $(PKGS))" ]; then
		echo "Usage: make install [pkg1] [pkg2] ..."
		exit 1
	fi
	$(H)for pkg in $(PKGS); do
		SRC_DIR="$(ROOT)/$$pkg"
		DST_DIR="$(CONF_HOME)/$$pkg"
		cp -rvf $$SRC_DIR $(CONF_HOME)/
		if [ -e "$$DST_DIR/Makefile" ]; then
			H=$(H) $(MAKE) --no-print-directory -C "$$DST_DIR" install || exit $$?
		elif [ -e "$$DST_DIR/install.sh" ]; then
			bash $$DST_DIR/install.sh
		fi
		printf -- "-- completed: $$pkg --\n\n"
	done

config:
	$(H)if [ -z "$(strip $(PKGS))" ]; then
		echo "Usage: make config [pkg1] [pkg2] ..."
		exit 1
	fi
	$(H)for pkg in $(PKGS); do
		DST_DIR="$(CONF_HOME)/$$pkg"
		if [ -e "$$DST_DIR/Makefile" ]; then
			H=$(H) $(MAKE) --no-print-directory -C "$$DST_DIR" config || exit $$?
		elif [ -e "$$DST_DIR/configure.sh" ]; then
			bash $$DST_DIR/configure.sh
		fi
	done

uninstall:
	$(H)if [ -z "$(strip $(PKGS))" ]; then
		echo "Usage: make uninstall [pkg1] [pkg2] ..."
		exit 1
	fi
	$(H)for pkg in $(PKGS); do
		if [ -d "$(CONF_HOME)/$$pkg" ]; then
			if [ -f "$(CONF_HOME)/$$pkg/Makefile" ]; then
				H=$(H) $(MAKE) --no-print-directory -C "$(CONF_HOME)/$$pkg" uninstall || true
			elif [ -f "$(CONF_HOME)/$$pkg/uninstall.sh" ]; then
				bash $(CONF_HOME)/$$pkg/uninstall.sh || true
			fi
			rm -rvf $(CONF_HOME)/$$pkg
		elif [ -e "$(CONF_HOME)/dotfile/$$pkg" ]; then
			if [ -f "$(CONF_HOME)/dotfile/$$pkg/Makefile" ]; then
				H=$(H) $(MAKE) --no-print-directory -C "$(CONF_HOME)/dotfile/$$pkg" uninstall || true
			elif [ -f "$(CONF_HOME)/dotfile/$$pkg/uninstall.sh" ]; then
				bash $(CONF_HOME)/dotfile/$$pkg/uninstall.sh || true
			fi
			rm -rvf $(CONF_HOME)/dotfile/$$pkg
			rm -rvf ~/.$$pkg
		fi
		echo "Remove Configuration: $$pkg"
	done

ifneq (,$(filter $(ACTION_TARGETS),$(MAKECMDGOALS)))
%:
	@:
endif

.PHONY: all install uninstall config $(LIST) $(ALIAS) bin
