PKG_NAME=tig
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
LOCAL_BIN=${HOME}/.local/bin
CUSTOMIZE_TIG=n

.ONESHELL:
config:
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)if [[ ! -e $(LOCAL_BIN) ]]; then
		mkdir $(LOCAL_BIN)
	fi
	git config --global alias.cmd '!bash -c "source $(CONFIG_DIR)/tig.bash; $$*"'
	$(H)ln -sf $(CONFIG_DIR)/tig.run $(LOCAL_BIN)
	$(H) if [[ $(CUSTOMIZE_TIG) == 'y' ]]; then
		mv $(CONFIG_DIR)/config $(CONFIG_DIR)/config.common
		echo source $(CONFIG_DIR)/config.common > $(CONFIG_DIR)/config
		echo "" >> $(CONFIG_DIR)/config
		cat $(CONFIG_DIR)/customize >> $(CONFIG_DIR)/config
	fi

install:
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)brew install tig

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package --"
	$(H)brew remove tig


.PHONY: config install uninstall
