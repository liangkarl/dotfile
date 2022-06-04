#!/usr/bin/env bash

config_dir=${XDG_CONFIG_HOME}

echo "-- setup nvim config --"

# link user-level config of EditorConfig
ln -sf ${config_dir}/nvim/editorconfig ~/.editorconfig
