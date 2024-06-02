PKG_NAME=tig
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)

.ONESHELL:
config.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)if [[ ! -e ~/bin ]]; then
		mkdir ~/bin
	fi
	$(H)ln -sf $(CONFIG_DIR)/tig.run ~/bin/

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)brew install tig

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove package --"
	$(H)brew remove tig

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
