#!/bin/bash

add_with_sig()
{
    local -r NOTE='GEN-BY-SCRIPT'
    local -r CONTENT=$1
    local -r FILE=$2
    local -r BY_WHO=${3:-sigh.sh}
    local -r DATE=$(date -I'date')
    local -r USR_STAMP="# $USERNAME|$BY_WHO|$NOTE"
    local -r TIME_STAMP="# $DATE created"

    # Default format:
    # # $USERNAME|$BY_WHO|$NOTE
    # # $DATE created
    # added content here
    #
    # Assume $USERNAME is from shell environment
    local -r SIGNED_STAMP="\n${USR_STAMP}\n${TIME_STAMP}\n\n${CONTENT}\n"
    echo -e "$SIGNED_STAMP" >> $FILE
}
