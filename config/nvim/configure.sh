#!/usr/bin/env bash

config_dir=${XDG_CONFIG_HOME}

echo "-- setup nvim config --"

# link user-level config of EditorConfig
ln -sf ${config_dir}/nvim/misc/editorconfig ~/.editorconfig
ln -sf ${config_dir}/nvim/misc/clang-format ~/.clang-format

nvim +"PlugInstall" <<< "Close the window after all of the plugins installed."
