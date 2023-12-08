#!/usr/bin/env bash

here="$(dirname $0)"

# $0 'config' 'backup'
query_saved() {
    local config backup value

    config="$1"
    backup="$2"

    if [[ "${ans,,}" == n ]]; then
        read -p "save new $config: [$backup] " value
    fi
    git config --global $config "${value:-$backup}"
}

# add username & email to git config
echo "-- setup git config --" 

# TODO:
# In the whole new environment, there may be some problem in git config
# due to no XDG_xx definition

username=$(git config --global user.name)
email=$(git config --global user.email)
username=${username:-$USER}
email=${email:-$USER@$HOSTNAME}
echo "current user.name = '$username'"
echo "current user.email = '$email'"

ans=x
while [[ ! "${ans:-y}" =~ [yYnN] ]]; do
    read -p 'do you want to keep the git config (Y/n) ' ans
done

mv -fv $here/config.new $here/config
mv -fv $here/ignore.new $here/ignore

echo "-- config name & email --"
query_saved user.name "$username"
query_saved user.email "$email"
