#!/bin/bash

create_link() {
    local SRC DST
    SRC=$1
    DST=$2

    echo "Link $SRC to $DST"
    ln -svib $SRC $DST
}

has_cmd() {
    command -v >&- "$@" &&
        return $GOOD ||
        return $BAD
}

has_these_cmds() {
    local LIST

    LIST="$1"
    for CMD in $LIST; do
        has_cmd $CMD || return $BAD
    done

    return $GOOD
}

setup_version() {
    local LINK NAME LIST PRIORITY
    LINK=$1
    NAME=$2
    # Seperated by " "
    LIST="$3"

    [ -z "$LINK" ] || [ -z "$NAME" ] || [ -z "LIST" ] && {
        show_err "invaild vars: [$LIST][$NAME][$LIST]"
            return $BAD
        }

    PRIORITY=10
    for LOCATION in $LIST; do
        sudo update-alternatives --install $LINK $NAME $LOCATION $PRIORITY
        PRIORITY=$((PRIORITY + 10))
    done
    sudo update-alternatives --config $NAME
}

# should be deprecated
install_if_no() {
    local CMD_NAME APT_NAME
    CMD_NAME="$1"
    APT_NAME=${2:-$CMD_NAME}
    has_cmd $CMD_NAME || sudo apt install $APT_NAME
}

add_ppa_repo() {
    local NAME
    NAME="$1"
    install_if_no add-apt-repository software-properties-common
    sudo add-apt-repository $NAME
    sudo apt update
}

get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
        grep '"tag_name":' |                                            # Get tag line
        sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

get_deb_from_github() {
    USER="$1"
    REPO="$2"
    curl -s https://api.github.com/repos/$USER/$REPO/releases/latest \
        | grep "browser_download_url.*_amd64.deb" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | wget -qi -
}

is_abs_path() {
    local TEST_PATH
    TEST_PATH="$1"
    [ "$TEST_PATH" == /* ] &&
        return $GOOD ||
        return $BAD
}

to_abs_path() {
    local SRC_PATH
    SRC_PATH="$1"
    [ -z "$SRC_PATH" ] || echo $(pwd)/$SRC_PATH
}

show_err() {
    local ARG CONTENT
    ARG="$1"
    CONTENT="$2"
    echo $ARG $CONTENT >&2
}
