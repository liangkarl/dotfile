XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=procps
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"

install:
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)if command -v top >/dev/null 2>&1; then
		echo "procps/top already available"
	elif [[ "$(OSTYPE)" == "Darwin" ]]; then
		echo "procps unavailable on macOS; skip"
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get update
		sudo apt-get install -y procps
	else
		echo "Unsupported OS: $(OSTYPE)"
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package/config --"
	$(H)if [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get remove -y procps || true
	fi
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
