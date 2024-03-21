PKG_NAME=enhancd
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
TMP=$(shell mktemp -d)
CMD=source $(CONFIG_DIR)/bootstrap.sh
INIT=source $(CONFIG_DIR)/init.sh

.ONESHELL:
config.$(PKG_NAME): install.$(PKG_NAME)
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)echo "$(INIT)" >> $(CONFIG_DIR)/bootstrap.sh
	$(H)grep -q -w "$(CMD)" ~/.bashrc ||
			echo -e "$(CMD)" >> ~/.bashrc

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): download and install latest version --"
	$(H)if [[ ! -d $(CONFIG_DIR)/.git ]]; then
		git clone -n --depth=1 https://github.com/b4b4r07/enhancd.git $(TMP)
		mv $(TMP)/.git $(CONFIG_DIR)
		rm -rf $(TMP)
		git -C $(CONFIG_DIR) reset --hard
	else
		git -C $(CONFIG_DIR) pull
	fi

remove.$(PKG_NAME):
	rm -rf $(CONFIG_DIR)

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
