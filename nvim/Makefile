config_dir=${XDG_CONFIG_HOME}/nvim

.ONESHELL:
nvim-conf:
	@echo "-- setup nvim config --"
	PS3='select a fuzzy finder above: '
	select opt in 'fzf' 'telescope' 'cancel'; do
		if [[ "$opt" != 'cancel' ]]; then
			echo "let g:fuzzy_finder = '$opt'" > ${config_dir}/config.vim
		fi
		break
	done
	@echo "let g:editor_theme = 'material'" >> ${config_dir}/config.vim
	@nvim +"nnoremap q <cmd>qa!<cr>" \
			+"set nomodifiable nomodified" \
			<<< "Press 'q' to exit nvim if all plugins were installed."

.PHONY: clang-format editorconfig nvim-conf
