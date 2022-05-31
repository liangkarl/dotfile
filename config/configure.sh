#!/usr/bin/env bash

set -eE -o functrace
shopt -s extglob
# set -xv

if (( ${BASH_VERSION//[!0-9]*/} < 4 )); then
    bash --version
    echo "please update BASH version at least to 4.x"
    exit 1
fi

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-${HOME}/.cache}
export OS="$(uname)"
export GIT_DB="$(mktemp)"

mydir="$(dirname $0)"
conf_home=${XDG_CONFIG_HOME}

echo "-- backup git config (global config) --"
git config --global --list > $GIT_DB

echo "-- trigger all config scripts --"

if [[ ! -e ${mydir}/config.list ]]; then
    echo "cannot find dir list"
    exit 2
fi
source ${mydir}/config.list

if [[ ! -e "$conf_home" ]]; then
    echo "create new config dir: $conf_home"
    mkdir $conf_home
else
    echo "'$conf_home' existed"
    PS3="select an option for th next action. "
    select option in 'remove' 'overwrite' 'cancel'; do
        case $option in
            remove)
                # FIXME: don't remove whole dir
                for dir in ${list[@]}; do
                    rm -rf $conf_home/$dir
                done
                ;;
            overwrite)
                break
                ;;
            cancel)
                exit 0
                ;;
        esac
    done
fi

# copy & config files
for dir in ${list[@]}; do
    echo "-- copy config to $conf_home/$dir --"
    cp -rvf ${mydir}/$dir $conf_home/

    [[ -e $conf_home/$dir/configure.sh ]] &&
        eval $conf_home/$dir/configure.sh
done

exit 0
