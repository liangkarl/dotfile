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

# Set CONFIG_ACTION=append, overwrite, or replace to apply the choice to
# every existing configuration directory without prompting. Append deep-merges
# JSON, TOML, and YAML with existing values taking precedence; other matching
# files are concatenated. Replace removes the existing directory first.
CONFIG_ACTION?=ask

LIST:=$(filter-out sys bin home config,$(shell ls -d -- */ | sed 's:/::'))
UNDER_HOME:=$(notdir $(wildcard $(ROOT)/home/*))
UNDER_CONFDIR:=$(notdir $(wildcard $(ROOT)/config/*))
ACTION_TARGETS:=install uninstall
PKGS:=$(filter-out $(ACTION_TARGETS),$(MAKECMDGOALS))

.ONESHELL:

all: $(LIST) bin home config

bin:
	$(H)mkdir -p $(XDG_LOCAL_BIN)
	$(H)cp -rvf $(ROOT)/bin/* $(XDG_LOCAL_BIN)

home: $(UNDER_HOME)

config: $(UNDER_CONFDIR)

$(UNDER_HOME) $(UNDER_CONFDIR) $(LIST):
	$(H)if [ -n "$(filter $(ACTION_TARGETS),$(MAKECMDGOALS))" ]; then
		exit 0
	fi

	$(H)if [ -f "$(ROOT)/home/$@" ]; then
		mkdir -p "$(HOME)" && cp -rvf "$(ROOT)/home/$@" "$(HOME)/.$@"
		exit $$?
	elif [ -f "$(ROOT)/config/$@" ]; then
		mkdir -p "$(CONF_HOME)" && cp -rvf "$(ROOT)/config/$@" "$(CONF_HOME)/$@"
		exit $$?
	fi

	$(H)$(eval SRC_DIR:=$(ROOT)/$@)
	$(H)$(eval DST_DIR:=$(CONF_HOME)/$@)

	$(H)mkdir -p "$(CONF_HOME)" || exit $$?
	$(H)if [ -d "$(DST_DIR)" ]; then
		config_action="$(CONFIG_ACTION)"
		if [ "$$config_action" = ask ]; then
			printf 'Configuration for %s already exists. Append, overwrite, or replace? [a/o/r] ' "$@"
			read -r config_action
		fi
		case "$$config_action" in
			a|A|append|APPEND)
				bash "$(ROOT)/bin/append-config" "$(SRC_DIR)" "$(DST_DIR)" || exit $$?
				;;
			o|O|overwrite|OVERWRITE)
				cp -rvf "$(SRC_DIR)" "$(CONF_HOME)/" || exit $$?
				;;
			r|R|replace|REPLACE)
				rm -rf "$(DST_DIR)" || exit $$?
				cp -rvf "$(SRC_DIR)" "$(CONF_HOME)/" || exit $$?
				;;
			*)
				echo 'Expected append, overwrite, or replace; no files were changed.'
				exit 1
				;;
		esac
	else
		cp -rvf "$(SRC_DIR)" "$(CONF_HOME)/" || exit $$?
	fi

	$(H)if [ -e $(DST_DIR)/Makefile ]; then
		H=$(H) $(MAKE) --no-print-directory -C "$(DST_DIR)" config || exit $$?
	elif [ -e $(DST_DIR)/configure.sh ]; then
		bash "$(DST_DIR)/configure.sh" || exit $$?
	fi

	$(H)printf -- "-- completed: $@ --\n\n"

install:
	$(H)if [ -z "$(strip $(PKGS))" ]; then
		echo "Usage: make install [pkg1] [pkg2] ..."
		exit 1
	fi
	$(H)for pkg in $(PKGS); do
		if [ -f "$(ROOT)/home/$$pkg" ]; then
			mkdir -p "$(HOME)"
			cp -vf "$(ROOT)/home/$$pkg" "$(HOME)/.$$pkg" || exit $$?
			continue
		elif [ -f "$(ROOT)/config/$$pkg" ]; then
			mkdir -p "$(CONF_HOME)"
			cp -vf "$(ROOT)/config/$$pkg" "$(CONF_HOME)/$$pkg" || exit $$?
			continue
		fi
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

uninstall:
	$(H)if [ -z "$(strip $(PKGS))" ]; then
		echo "Usage: make uninstall [pkg1] [pkg2] ..."
		exit 1
	fi
	$(H)for pkg in $(PKGS); do
		if [ -f "$(ROOT)/home/$$pkg" ]; then
			rm -vf "$(HOME)/.$$pkg"
		elif [ -f "$(ROOT)/config/$$pkg" ]; then
			rm -vf "$(CONF_HOME)/$$pkg"
		elif [ -d "$(CONF_HOME)/$$pkg" ]; then
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

.PHONY: all $(ACTION_TARGETS) $(UNDER_HOME) $(UNDER_CONFDIR) $(LIST) bin home config
