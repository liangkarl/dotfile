PKG_NAME   := git
CONFIG_DIR := ${XDG_CONFIG_HOME}/$(PKG_NAME)
MK_PATH    := $(abspath $(lastword $(MAKEFILE_LIST)))
MK_DIR     := $(shell dirname $(MK_PATH))
USERNAME   := $(shell git config --global user.name)
EMAIL      := $(shell git config --global user.email)
USERNAME   ?= ${USER}
EMAIL      ?= ${USER}@${HOSTNAME}

define query_saved
	read -p "save new $1: [$2] " value
	if [[ -z "$${value}" ]]; then
		git config --global $1 "$2"
	else
		git config --global $1 "$${value}"
	fi
endef

.ONESHELL:
config.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)echo "current user.name = '$(USERNAME)'"
	$(H)echo "current user.email = '$(EMAIL)'"

	mv -vf $(CONFIG_DIR)/ignore.new $(CONFIG_DIR)/ignore
	mv -vf $(CONFIG_DIR)/config.new $(CONFIG_DIR)/config

	$(call query_saved,user.name,$(USERNAME))
	$(call query_saved,user.email,$(EMAIL))


install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install package --"

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove package --"

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
