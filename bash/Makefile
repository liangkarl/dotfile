PKG_NAME   := bash
CONFIG_DIR := ${XDG_CONFIG_HOME}/$(PKG_NAME)
COMPL_DIR  := ${XDG_DATA_HOME}/bash-completion
MK_PATH    := $(abspath $(lastword $(MAKEFILE_LIST)))
MK_DIR     := $(shell dirname $(MK_PATH))

.ONESHELL:
config.$(PKG_NAME): # Run in $(CONFIG_DIR)
	$(H)echo "-- $(PKG_NAME): setup config --"
	$(H)$(eval f=${HOME}/.bash_profile)
	$(H)$(eval cmd="source ${HOME}/.bashrc")
	$(H)if [ -e $f ] && ! grep -q ${cmd} $f; then
		echo "-- configure $f --"
		cat >> $f <<-EOF
		[ -f ${HOME}/.bashrc ] && $(shell echo ${cmd})
		$(shell echo "")
		EOF
	fi

	$(eval f=${HOME}/.bashrc)
	$(eval init=${MK_DIR}/init.bash)
	$(eval cmd="source ${init}")
	$(H)if [ ! -e "$f" ]; then
		echo "Error: Cannot found .bashrc. Please add the command manually."
		echo "Error:"
		echo "Error: ${cmd}"
		echo "Error:"
	else
		if ! grep -q ${cmd} $f; then
			echo "-- configure $f --"
			cat >> $f <<-EOF
			# Load dotfile bash config
			$(shell echo ${cmd})
			$(shell echo "")
			EOF
		fi
	fi

	$(H)if [ ! -e "${COMPL_DIR}" ]; then
		mkdir ${COMPL_DIR}
	fi
	$(H)cp -rvf ${MK_DIR}/completion/* ${COMPL_DIR}
	$(H)echo "-- add bash-completion completed --"

	# $SHELL is from environment
	$(H)if realpath ${SHELL} | grep -q 'dash'; then
		sudo dpkg-reconfigure dash
	fi

	$(H)echo "** Please restart console to apply new bash configuration **"

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install package --"

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove package --"
	rm -rf $(MK_DIR)

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
