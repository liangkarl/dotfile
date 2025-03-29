PKG_NAME=enhancd
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
ENHANCD=${CONFIG_DIR}/${PKG_NAME}.git
SHELL:=bash

.ONESHELL:
config.$(PKG_NAME): install.$(PKG_NAME)
	$(H)echo "-- $(PKG_NAME): setup config --"

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)if [[ -e $(ENHANCD) ]]; then
		git -C $(ENHANCD) pull
	else
		git clone https://github.com/b4b4r07/enhancd.git $(ENHANCD)
	fi

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove package --"
	$(H)rm -rf $(CONFIG_DIR)

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
