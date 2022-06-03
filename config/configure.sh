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

list=()
while IFS= read -r line; do
    list+=("$line")
done < ${mydir}/config.list

if [[ ! -e "$conf_home" ]]; then
    echo "create new config dir: $conf_home"
    mkdir $conf_home
fi

# copy & config files
options=("remove" "overwrite" "skip" "cancel")

for dir in ${list[@]}; do
    target="$conf_home/$dir"

    echo "-- copy config to $target --"

    [[ ! -e $target ]] && {
        cp -rvf $mydir/$dir $conf_home
        continue
    }

    PS3="Found an old config. Select the next action: "
    select option in ${options[@]}; do
        case $option in
            remove)
                rm -rf $target
                ;;
            overwrite)
                break
                ;;
            skip)
                continue 2
                ;;
            cancel)
                exit 0
                ;;
        esac
        break
    done

    cp -rvf ${mydir}/$dir $conf_home/

    [[ -e $target/configure.sh ]] &&
        eval $target/configure.sh
done

exit 0
