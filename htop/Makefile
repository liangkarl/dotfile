XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=htop
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"

install:
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)if command -v htop >/dev/null 2>&1; then
		echo "htop already installed"
	elif [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew install htop
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get update
		sudo apt-get install -y htop
	else
		echo "Unsupported OS: $(OSTYPE)"
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package/config --"
	$(H)if [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew uninstall htop || true
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get remove -y htop || true
	fi
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
