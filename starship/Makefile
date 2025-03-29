PKG_NAME=starship
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
TMP:=$(shell mktemp -d)
CMD=source $(CONFIG_DIR)/bootstrap.sh
# BLE_CMD=source $(CONFIG_DIR)/ble.sh/out/ble.sh
SHELL:=bash

.ONESHELL:
config.$(PKG_NAME): install.$(PKG_NAME)
	$(H)echo "-- $(PKG_NAME): setup config --"
#	echo "${BLE_CMD}" >> ${CONFIG_DIR}/bootstrap.sh

install.$(PKG_NAME):
	$(H)lib.load devel
	$(H)if [[ -z "$(shell which ${PKG_NAME})" ]]; then
		$(H)echo "-- $(PKG_NAME): install package --"
		brew install ${PKG_NAME}
	fi
# depenency
	$(H)if [[ ! -e ./ble.sh ]]; then
		git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
#		make -C ble.sh install PREFIX=~/.local
		make -C ble.sh
	fi

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove package --"
	$(H)rm -rf $(CONFIG_DIR)

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
