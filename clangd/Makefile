XDG_CONFIG_HOME ?= ${HOME}/.config

PKG_NAME=clangd
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
OSTYPE=$(shell uname)

.ONESHELL:

config:
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)test -f "${CONFIG_DIR}/config.yaml" && echo "clangd config ready"

install:
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)if command -v clangd >/dev/null 2>&1; then
		echo "clangd already installed"
	elif [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew install llvm
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get update
		sudo apt-get install -y clangd
	else
		echo "Unsupported OS: $(OSTYPE)"
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove config --"
	$(H)if [[ "$(OSTYPE)" == "Darwin" ]]; then
		brew uninstall llvm || true
	elif [[ "$(OSTYPE)" == "Linux" ]]; then
		sudo apt-get remove -y clangd || true
	fi
	$(H)rm -rf "${CONFIG_DIR}"


.PHONY: config install uninstall
