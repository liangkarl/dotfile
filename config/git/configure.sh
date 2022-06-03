#!/usr/bin/env bash

# $0 'config' 'backup'
query_saved() {
    local ans config backup value

    config="$1"
    backup="$2"

    if [[ -n "$backup" ]] &&
            read -p "keep old git user name: '${backup_name}'? [Y/n] " ans &&
            [[ "${ans,,}" == 'n' ]]; then
        value=$backup
    else
        read -p 'save new git '$config': [empty to skip] ' value
    fi

    [[ -z "$config" ]] && exit 2

    git config $config "$value"
}

trap "rm -rf ${GIT_DB}" 0

# add username & email to git config
echo "-- setup git config --"

read -p 'do you want to restore git config (Y/n) ' ans
if [[ "${ans,,}" != 'n' ]]; then
    while read -u 10 prop; do
        key=${prop%%=*}
        val=${prop#*=}
        echo "$key = $val"
        git config --global $key "$val"
    done 10< "$GIT_DB"
fi

echo "-- config name & email --"
query_saved user.name "$(git config --global user.name)"
query_saved user.email "$(git config --global user.email)"
