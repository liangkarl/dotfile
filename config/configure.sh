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

# backup old git name & email
backup_name="$(git config --global user.name 2>&- || true)"
backup_email="$(git config --global user.email 2>&- || true)"

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
has_init="$(cat ${bashrc} | grep "${import}" || true)"
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

if [[ -n "$backup_name" ]]; then
    read -p "keep old git user name: '${backup_name}'? [Y/n] " ans
    if [[ "${ans,,}" != 'n' ]]; then
        name=$backup_name
    else
        read -p 'save new git user name: [empty to skip] ' name
    fi
else
    read -p 'save new git user name: [empty to skip] ' name
fi
if [[ -n "${name}" ]]; then
    git config --global user.name "$name"
fi

if [[ -n "$backup_email" ]]; then
    read -p "keep old git user email: '${backup_email}'? [Y/n] " ans
    if [[ "${ans,,}" != 'n' ]]; then
        email=$backup_email
    else
        read -p 'save new git user email: [empty to skip] ' email
    fi
else
    read -p 'save new git user email: [empty to skip] ' email
fi
if [[ -n "${email}" ]]; then
    git config --global user.email "$email"
fi
