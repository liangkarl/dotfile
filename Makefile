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

# Set CONFIG_ACTION=append or CONFIG_ACTION=overwrite to apply the choice to
# every existing configuration directory without prompting. Append deep-merges
# JSON, TOML, and YAML with existing values taking precedence; other matching
# files are concatenated.
CONFIG_ACTION?=ask

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

	$(H)if [ -d "$(DST_DIR)" ]; then
		config_action="$(CONFIG_ACTION)"
		if [ "$$config_action" = ask ]; then
			printf 'Configuration for %s already exists. Append or overwrite? [a/o] ' "$@"
			read -r config_action
		fi
		case "$$config_action" in
			a|A|append|APPEND)
				bash "$(ROOT)/bin/append-config" "$(SRC_DIR)" "$(DST_DIR)"
				;;
			o|O|overwrite|OVERWRITE)
				rm -rf "$(DST_DIR)"
				cp -rvf "$(SRC_DIR)" "$(CONF_HOME)/"
				;;
			*)
				echo 'Expected append or overwrite; no files were changed.'
				exit 1
				;;
		esac
	else
		cp -rvf "$(SRC_DIR)" "$(CONF_HOME)/"
	fi
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
