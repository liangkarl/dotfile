#!/usr/bin/env bash -e

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

if [[ -z "$(which git)" ]]; then
    echo "please install git to config username & email."
    exit 1
fi

read -p 'do you want to restore git config (Y/n) ' ans
if [[ "$ans" != 'n' ]]; then
    for prop in $(<${GIT_DB}); do
        git config --global ${prop//=/ }
    done
else
    query_saved user.name
    query_saved user.email
fi