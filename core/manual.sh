WHERE="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)}"

. $WHERE/env.sh
init_env

unset WHERE
