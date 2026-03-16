# ==============================================================================
# Context-Aware History Search (V31 - Performance + Intelligent Fallback)
# ==============================================================================

_context_history_search() {
    local direction=$1
    local current_line="$READLINE_LINE"
    local cursor_pos="$READLINE_POINT"

    # 1. 修正游標異常 (解決某些環境下回傳 0 的問題)
    if [[ $cursor_pos -eq 0 && ${#current_line} -gt 0 ]]; then
        cursor_pos=${#current_line}
    fi

    # 2. 狀態重設與快取建立 (僅在搜尋條件改變時執行一次)
    if [[ "$current_line" != "$_chs_last_result" || "$cursor_pos" != "$_chs_last_pos" ]]; then
        _chs_orig_line="$current_line"
        _chs_orig_prefix="${current_line:0:cursor_pos}"
        _chs_orig_suffix="${current_line:cursor_pos}"
        _chs_index=0

        # 同步當前視窗歷史
        history -a; history -c; history -r

        # 3. 極速一次性掃描：同時計算精確匹配與全歷史備份
        _chs_match_list=()
        mapfile -t _chs_match_list < <(HISTTIMEFORMAT= history 5000 | awk -v orig="$_chs_orig_line" -v pref="$_chs_orig_prefix" -v suff="$_chs_orig_suffix" '
            {
                # 移除行首行號 (取代 sed)
                sub(/^[ ]*[0-9]+[ ]+/, "");

                # 排除空行、重複行、以及目前這行
                if ($0 == "" || seen[$0]++ || $0 == orig) next;

                # 記錄全歷史 (用於 Fallback)
                all_history[all_count++] = $0;

                # 精確匹配判定
                match_ok = 0;
                if (suff != "") {
                    # 行中搜尋: prefix...suffix
                    if (index($0, pref) == 1 && substr($0, length($0)-length(suff)+1) == suff) match_ok = 1;
                } else {
                    # 行末搜尋: prefix...
                    if (index($0, pref) == 1) match_ok = 1;
                }

                # 存入陣列待最後反轉 (取代 tac/tail -r)
                if (match_ok) results[count++] = $0;
            }
            END {
                if (count > 0) {
                    # 輸出精確匹配結果 (倒序)
                    for (i = count - 1; i >= 0; i--) print results[i];
                } else if (suff == "") {
                    # 只有在行尾模式且找不到精確結果時，才輸出全歷史 (Fallback)
                    for (i = all_count - 1; i >= 0; i--) print all_history[i];
                }
            }')
    fi

    local match_count=${#_chs_match_list[@]}

    # 4. 索引遍歷 (純記憶體操作)
    if [[ "$direction" == "up" ]]; then
        ((_chs_index++))
        [[ $_chs_index -gt $match_count ]] && _chs_index=$match_count
    else
        ((_chs_index--))
        if [[ $_chs_index -lt 1 ]]; then
            # 回到最初輸入的內容
            READLINE_LINE="$_chs_orig_line"
            READLINE_POINT=${#_chs_orig_prefix}
            _chs_last_result="$_chs_orig_line"
            _chs_last_pos="$READLINE_POINT"
            _chs_index=0
            return
        fi
    fi

    # 5. 套用結果 (只有內容變動時才寫入，減少閃爍)
    if [[ $match_count -gt 0 ]]; then
        local selected="${_chs_match_list[$((_chs_index - 1))]}"

        if [[ "$READLINE_LINE" != "$selected" ]]; then
            READLINE_LINE="$selected"
        fi

        # 維持游標邏輯
        if [[ -z "$_chs_orig_suffix" ]]; then
            READLINE_POINT=${#selected}
        else
            READLINE_POINT=${#_chs_orig_prefix}
        fi

        _chs_last_result="$selected"
        _chs_last_pos="$READLINE_POINT"
    fi
}

# 輔助 Function 與綁定
_chs_up() { _context_history_search "up"; }
_chs_down() { _context_history_search "down"; }

bind -r "\e[A" 2>/dev/null; bind -r "\eOA" 2>/dev/null
bind -r "\e[B" 2>/dev/null; bind -r "\eOB" 2>/dev/null

bind -x '"\e[A": _chs_up'
bind -x '"\eOA": _chs_up'
bind -x '"\e[B": _chs_down'
bind -x '"\eOB": _chs_down'
