#!/bin/bash

t() {
	echo "t(): src0:${BASH_SOURCE[0]}"
	echo "t(): src1:${BASH_SOURCE[1]}"
	echo "t(): dbg_list:${__DEVEL_BASH_DBG_SPACE_LIST[@]}"
	echo "t(): cur_list:${__DEVEL_BASH_CUR_SPACE_LIST[@]}"
	msg.dbg "t(): dbg.msg!!!"
}

lib.load devel
b=$(dbg.mark)
# dbg.on $b

echo "t.sh: dbg_list:${__DEVEL_BASH_DBG_SPACE_LIST[@]}"
echo "t.sh: cur_list:${__DEVEL_BASH_CUR_SPACE_LIST[@]}"
echo "t.sh: src0:${BASH_SOURCE[0]}"
echo "t.sh: src1:${BASH_SOURCE[1]}"
msg.dbg "dbg.msg!!!"
