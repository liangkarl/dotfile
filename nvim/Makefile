PKG_NAME=nvim
CONFIG_DIR=${XDG_CONFIG_HOME}/$(PKG_NAME)
NVIM_VER=0.9.4

.ONESHELL:
config.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): setup config --"
	# TODO: implement different fuzzy_finder
	# PS3='select a fuzzy finder above: '
	# $(H)select opt in 'fzf' 'telescope' 'cancel'; do
	# 	if [[ "${opt}" != 'cancel' ]]; then
	# 		echo "let g:fuzzy_finder = '${opt}'" > ${CONFIG_DIR}/config.vim
	# 	fi
	# 	break
	# done
	$(H)echo "let g:editor_theme = 'material'" > ${CONFIG_DIR}/config.vim
	$(H)nvim +"set nomodifiable nomodified" \
			<<< "Press 'q' to exit nvim if all plugins were installed."

install.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): install package --"
	$(H)brew install neovim@${NVIM_VER}

remove.$(PKG_NAME):
	$(H)echo "-- $(PKG_NAME): remove package --"
	$(H)brew remove neovim

.PHONY: config.$(PKG_NAME) install.$(PKG_NAME) remove.$(PKG_NAME)
