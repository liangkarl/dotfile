lib.add() {
    if [[ -z "$SHELL_DIR" ]]; then
        echo "$SHELL_DIR wasn't defined"
        return 1
    elif [[ ! -e "$SHELL_DIR" ]]; then
        echo "'$SHELL_DIR' wasn't existed"
        return 2
    elif [[ -z "$1" ]]; then
        echo "Empty input"
        return 3
    elif [[ ! -e "$SHELL_DIR/lib/$1" ]]; then
        echo "'$1' doesn't exist"
        return 4
    fi

    source "$SHELL_DIR/lib/$1"
}

path.dup() {
    # Remove duplicated path
    PATH=$(echo -n $PATH | awk 'BEGIN {RS=":"; ORS=":"} !a[$0]++')
    PATH=${PATH%:}
}

export -f lib.add
export -f path.dup
