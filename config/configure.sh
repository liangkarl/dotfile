#!/bin/bash

set -eE -o functrace

# show error command & line
failure() {
  local lineno=$1
  local msg=$2
  echo "Failed at $lineno: $msg"
}
trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

# check XDG_CONFIG_HOME dir
config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}"
if [[ ! -e "$config_dir" ]]; then
    mkdir $config_dir
fi

# copy config files
self="$(basename $0)"
self_dir="$(dirname $0)"
shopt -s extglob
echo "-- copy config to $config_dir --"
cp -vr ${self_dir}/!(${self}) ${config_dir}/

# add customized variable
echo "-- add path of shell dir --"
echo "export SHELL_DIR=$(readlink -e ${self_dir}/..)" |
        tee ${config_dir}/bash/config

# import setup in .bashrc
echo "-- import setup in .bashrc --"
bashrc=~/.bashrc
import="source ${config_dir}/bash/init.bash"
has_init="$(cat ${bashrc} | grep "${import}")"
if [[ -z "$has_init" ]]; then
    echo $import >> ${bashrc}
fi

# add username & email to git config
echo "-- setup git config --"
git_dir=${config_dir}/git
if [[ -z "$(which git)" ]]; then
    echo "warning: please install git to config username & email."
    exit
fi
read -p 'give me a name for git in user-level config. (empty to ignore): ' name
if [[ -n "$name" ]]; then
    git config --global user.name "$name"
fi
read -p 'give me an email for git in user-level config. (empty to ignore): ' email
if [[ -n "$email" ]]; then
    git config --global user.email "$email"
fi
