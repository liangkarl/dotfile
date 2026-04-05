XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=broot
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"

install:
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)if command -v broot >/dev/null 2>&1; then
		echo "broot already installed"
	elif [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew install broot
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get update
		sudo apt-get install -y broot
	else
		echo "Unsupported OS: $(OSTYPE)"
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package/config --"
	$(H)if [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew uninstall broot || true
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get remove -y broot || true
	fi
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
