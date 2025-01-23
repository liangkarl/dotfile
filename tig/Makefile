PKG_NAME=tig
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
LOCAL_BIN=${HOME}/.local/bin

.ONESHELL:
config.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)if [[ ! -e $(LOCAL_BIN) ]]; then
		mkdir $(LOCAL_BIN)
	fi
	$(H)ln -sf $(CONFIG_DIR)/tig.run $(LOCAL_BIN)

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)brew install tig

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove package --"
	$(H)brew remove tig

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
