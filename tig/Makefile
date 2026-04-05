PKG_NAME=tig
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
LOCAL_BIN=${HOME}/.local/bin

.ONESHELL:
config:
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)if [[ ! -e $(LOCAL_BIN) ]]; then
		mkdir $(LOCAL_BIN)
	fi
	git config --global alias.cmd '!bash -c "source $(CONFIG_DIR)/tig.bash; $$*"'
	$(H)ln -sf $(CONFIG_DIR)/tig.run $(LOCAL_BIN)

install:
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)brew install tig

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package --"
	$(H)brew remove tig


.PHONY: config install uninstall
