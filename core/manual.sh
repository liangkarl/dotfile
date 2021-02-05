__manual_install__() {
    local CORE_DIR

    CORE_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)}"

    . $CORE_DIR/env.sh
    init_env
}

__manual_install__
unset __manual_install__
