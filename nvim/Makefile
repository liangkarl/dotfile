CONFIG_DIR=${XDG_CONFIG_HOME}/nvim
NVIM_VER=0.9.4

.ONESHELL:
config.nvim:
	$(H)echo "-- setup nvim config --"
	PS3='select a fuzzy finder above: '
	$(H)select opt in 'fzf' 'telescope' 'cancel'; do
		if [[ "${opt}" != 'cancel' ]]; then
			echo "let g:fuzzy_finder = '${opt}'" > ${CONFIG_DIR}/config.vim
		fi
		break
	done
	$(H)echo "let g:editor_theme = 'material'" >> ${CONFIG_DIR}/config.vim
	$(H)nvim +"nnoremap q <cmd>qa!<cr>" \
			+"set nomodifiable nomodified" \
			<<< "Press 'q' to exit nvim if all plugins were installed."

install.nvim:
	$(H)brew install neovim@${NVIM_VER}

remove.nvim:
	$(H)brew remove neovim

.PHONY: config.nvim
