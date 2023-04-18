#!/usr/bin/env bash

config_dir=${XDG_CONFIG_HOME}/nvim

echo "-- setup nvim config --"

PS3='select a fuzzy finder above: '
select opt in 'fzf' 'telescope' 'cancel'; do
    if [[ "$opt" != 'cancel' ]]; then
        echo "let g:fuzzy_finder = '$opt'" > ${config_dir}/config.vim
    fi
    break
done
echo "let g:editor_theme = 'material'" >> ${config_dir}/config.vim

# link user-level config of EditorConfig
ln -sf ${config_dir}/misc/editorconfig ~/.editorconfig
ln -sf ${config_dir}/misc/clang-format ~/.clang-format

nvim +"PlugInstall" <<< "Close the window after all of the plugins installed."
