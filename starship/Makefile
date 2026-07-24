PKG_NAME=starship
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
CONFIG_KEY=__STARSHIP_INCLUDED__
TMP:=$(shell mktemp -d)
CMD=source $(CONFIG_DIR)/bootstrap.sh
SHELL:=bash

.ONESHELL:
config:
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)if ! grep -q ${CONFIG_KEY} ${XDG_CONFIG_HOME}/bash/external.bash; then
		echo "### ${CONFIG_KEY} ###"
		echo "source ${CONFIG_DIR}/bootstrap.sh"
		echo ""
	fi >> ${XDG_CONFIG_HOME}/bash/external.bash

install:
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

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package --"
	$(H)rm -rf $(CONFIG_DIR)


.PHONY: config install uninstall
