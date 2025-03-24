#!/usr/bin/env bash

[[ -v __ANSI_BASH_INCLUDED ]] && return
__ANSI_BASH_INCLUDED='none'

sys.stage_start

_BOLD='\e[1m'
_FADE='\e[2m'
_ITL='\e[3m'
_ULINE='\e[4m'
_DULINE='\e[21m'
_FLASH='\e[5m'
_RVRS='\e[7m'
_CRSO='\e[9m'
_RS='\e[0m'

# ansi [RGB] [RGB]
# r/g/b values are only available from 0-2
# 8/16-bit
# FG: 30-37, 40-47, 8bit
# BG: 90-97, 100-107, 8bit
ansi() {
    local r g b i ofs

    for i in 30 40; do
        ofs=0
        if [[ -n "$1" ]]; then
            b=$((0x$1 & 0xf))
            g=$(((0x$1 >> 4) & 0xf))
            r=$(((0x$1 >> 8) & 0xf))
            if [[ $b -gt 1 ]]; then
                ofs=60
                b=1
            fi
            if [[ $g -gt 1 ]]; then
                ofs=60
                g=1
            fi
            if [[ $r -gt 1 ]]; then
                ofs=60
                r=1
            fi
            echo -n "\e[$((${i}+${ofs}+${r:-0}+2*${g:-0}+4*${b:-0}))m"
        fi
        shift
    done
}

# ansi_256 [RGB] [RGB]
# r/g/b values are only available from 0-5
# 16-bit colors
# 6*6*6=216 colors
# 24*grey colors
# TODO: only support 216 colors
ansi_256() {
    local r g b

    for i in 38 48; do
        if [[ -n "$1" ]]; then
            b=$((0x$1 & 0xf))
            g=$(((0x$1 >> 4) & 0xf))
            r=$(((0x$1 >> 8) & 0xf))
            echo -n "\e[${i};5;$((16+36*${r:-0}+6*${g:-0}+${b:-0}))m"
        fi
        shift
    done
}

# ansi_tc [RRGGBB] [RRGGBB]
# ansi true color
ansi_tc() {
    local rr gg bb

    for i in 38 48; do
        if [[ -n "$1" ]]; then
            bb=$((0x$1 & 0xff))
            gg=$(((0x$1 >> 8) & 0xff))
            rr=$(((0x$1 >> 16) & 0xff))
            echo -n "\e[${i};2;${rr:-0};${bb:-0};${gg:-0}m"
        fi
        shift
    done
}

sys.stage_stop
