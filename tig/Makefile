PKG_NAME=tig
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)

.ONESHELL:
config.$(PKG_NAME):
	$(H)echo "-- setup $(PKG_NAME) config --"
	$(H)if [[ ! -e ~/bin ]]; then
		mkdir ~/bin
	fi
	$(H)ln -sf $(CONFIG_DIR)/tig.cmd ~/bin/

install.$(PKG_NAME):
	$(H)brew install tig

remove.$(PKG_NAME):
	$(H)brew remove tig

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
