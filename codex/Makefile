PKG_NAME   := codex
CONFIG_DIR := ${XDG_CONFIG_HOME}/$(PKG_NAME)
CONFIG_KEY :=__CODEX_INCLUDED__
MK_PATH    := $(abspath $(lastword $(MAKEFILE_LIST)))
MK_DIR     := $(shell dirname $(MK_PATH))

.ONESHELL:
config: # Run in $(CONFIG_DIR)
	$(H)if ! grep -q ${CONFIG_KEY} ${XDG_CONFIG_HOME}/bash/external.bash; then
		echo "### ${CONFIG_KEY} ###"
		echo "export CODEX_HOME=${MK_DIR}"
		echo ""
	fi >> ${XDG_CONFIG_HOME}/bash/external.bash
	ln -sf ${CONFIG_DIR} ${HOME}/.codex

install:
	$(H)echo "-- $(PKG_NAME): install package --"

uninstall:
	$(H)echo "-- $(PKG_NAME): remove package --"
	# rm -rf $(MK_DIR)

.PHONY: config install uninstall
