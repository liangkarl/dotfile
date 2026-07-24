PKG_NAME=enhancd
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
CONFIG_KEY=__ENHANCD_INCLUDED__
ENHANCD=${CONFIG_DIR}/${PKG_NAME}.git
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
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)if [[ -e $(ENHANCD) ]]; then
		git -C $(ENHANCD) pull
	else
		git clone https://github.com/b4b4r07/enhancd.git $(ENHANCD)
	fi

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package --"
	$(H)rm -rf $(CONFIG_DIR)


.PHONY: config install uninstall
