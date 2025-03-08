#!/bin/bash
echo "s.sh: src0:${BASH_SOURCE[0]}"
echo "s.sh: src1:${BASH_SOURCE[1]}"

lib.add config
msg.info "lib.add config"
msg.dbg config!!!

msg.info "======= lib.add devel"
lib.add devel
a=$(dbg.mark)
msg.info "lib.add devel"

dbg.on
# dbg.on $a

msg.info "dbg_list:${__DEVEL_BASH_DBG_SPACE_LIST[@]}"
msg.info "cur_list:${__DEVEL_BASH_CUR_SPACE_LIST[@]}"
msg.dbg devel!!!

msg.info "======= . t.sh"
. $(dirname $0)/t.sh
# dbg.on t.sh
t
dbg.off

lib.add menu
msg.info "lib.add menu"
msg.dbg menu!!!

msg.info "======= bash t.sh"
bash $(dirname $0)/t.sh
msg.info "======="

