# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_CONFIG_HOME?=${HOME}/.config
XDG_DATA_HOME?=${HOME}/.local/share
XDG_CACHE_HOME?=${HOME}/.cache
TOP:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CONF_HOME:=${XDG_CONFIG_HOME}

H=@

-include $(TOP)/package.mk
-include $(TOP)/dotfile.mk

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

.PHONY: all %.remove %.install %.uninstall
