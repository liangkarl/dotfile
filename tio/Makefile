XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=tio
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"

install:
	# Development
	# Using /dev/ttyUSBX without root permissions
	# sudo usermod -aG dialout "$USER"
	# newgrp dialout
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)if command -v tio >/dev/null 2>&1; then
		echo "tio already installed"
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		brew install tio
	else
		echo "Unsupported OS: $(OSTYPE)"
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package/config --"
	$(H)if [[ "$(OSTYPE)" == "Linux" ]]; then
		brew uninstall tio || true
	fi
	$(H)rm -rf "${CONFIG_DIR}"

.PHONY: config install uninstall
