#!/bin/bash

add_with_sig()
{
    local NOTE CONTENT FILE BY_WHO DATE USR_STAMP TIME_STAMP
    local SIGNED_STAMP

    NOTE='GEN-BY-SCRIPT'
    CONTENT=$1
    FILE=$2
    BY_WHO=${3:-sigh.sh}
    DATE=$(date -I'date')
    USR_STAMP="# $USER|$BY_WHO|$NOTE"
    TIME_STAMP="# $DATE created"

    # Default format:
    # # $USER|$BY_WHO|$NOTE
    # # $DATE created
    # added content here
    #
    # Assume $USER is from shell environment
    SIGNED_STAMP="\n${USR_STAMP}\n${TIME_STAMP}\n${CONTENT}"
    echo -e "$SIGNED_STAMP" >> $FILE
}
