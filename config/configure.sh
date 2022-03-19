#!/usr/bin/env bash -e

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

git config --global --list > $GIT_DB

this_dir="$(dirname $0)"

echo "-- trigger all config scripts --"

if [[ ! -e ${this_dir}/config.txt ]]; then
    echo "cannot find dir list"
    exit 2
fi
source ${this_dir}/config.txt

# check XDG_CONFIG_HOME dir
config_dir=${XDG_CONFIG_HOME}
if [[ ! -e "$config_dir" ]]; then
    echo "create new config dir: $config_dir"
    mkdir $config_dir
else
    echo "'$config_dir' existed"
    PS3="select an option for th next action. "
    select option in 'remove' 'overwrite' 'cancel'; do
        case $option in
            remove)
                # FIXME: don't remove whole dir
                for sdir in ${list[@]}; do
                    rm -rf $config_dir/$sdir
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
for sdir in ${list[@]}; do
    echo "-- copy config to $config_dir/$sdir --"
    cp -rvf ${this_dir}/$sdir $config_dir/

    [[ -e $config_dir/$sdir/configure.sh ]] &&
        eval $config_dir/$sdir/configure.sh
done

exit 0
