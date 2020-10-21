#!/bin/bash

declare -r __MAGIC='AUTO-GEN-BY-SCRIPT'
declare -r __BEGIN='BEGIN'
declare -r __END='END'
__ADDED_CONTENT=
__SCRIPT_NAME=

append_sign_and_content()
{
        local -r FILE=$1
        local -r SIGNED_STAMP=$(gen_stamp)
        echo -e "$SIGNED_STAMP" >> $FILE
}

check_sign()
{
        echo "TODO: $0"
}

remove_sign_and_content()
{
        echo "TODO: $0"
}

init_sign()
{
        __SCRIPT_NAME=$1
        __ADDED_CONTENT=$2
}

gen_stamp()
{
        local -r DATE=$(date -I'date')
        local -r FIRST_STAMP="## $USERNAME|$__SCRIPT_NAME|$__MAGIC|$__BEGIN"
        local -r TIME_STAMP="## $DATE created"
        local -r LAST_STAMP="## $USERNAME|$__SCRIPT_NAME|$__MAGIC|$__END"

# Default format:
# ## $USERNAME|$SCRIPTNAME|$__MAGIC|$__BEGIN
# ## $DATE created
# added content here
# ## $USERNAME|$SCRIPTNAME|$__MAGIC|$__END
#
# Assume $USERNAME is from shell environment 

# RAW Ouput
        echo "
${FIRST_STAMP}
${TIME_STAMP}

${__ADDED_CONTENT}

${LAST_STAMP}"
}
