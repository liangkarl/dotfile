PKG_NAME=enhancd
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
TMP:=$(shell mktemp -d)
CMD=source $(CONFIG_DIR)/bootstrap.sh
INIT=source $(CONFIG_DIR)/init.sh

.ONESHELL:
config.$(PKG_NAME): install.$(PKG_NAME)
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)echo "$(INIT)" >> $(CONFIG_DIR)/bootstrap.sh
	$(H)grep -q -w "$(CMD)" ~/.bashrc ||
			printf -- "$(CMD)\n" >> ~/.bashrc

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install package --"
	rm -rf $(CONFIG_DIR)/.git
	git clone -n --depth=1 https://github.com/b4b4r07/enhancd.git $(TMP)
	cp -rf $(TMP)/.git $(CONFIG_DIR)
	rm -rf $(TMP)
	git -C $(CONFIG_DIR) reset --hard

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove package --"
	$(H)rm -rf $(CONFIG_DIR)

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
