# ==============================================================================
# Context-Aware History Search (V31 - Performance + Intelligent Fallback)
# ==============================================================================

_context_history_search() {
    local direction=$1
    local current_line="$READLINE_LINE"
    local cursor_pos="$READLINE_POINT"

    # 修正游標異常 (解決某些環境下回傳 0 的問題)
    if [[ $cursor_pos -eq 0 && ${#current_line} -gt 0 ]]; then
        cursor_pos=${#current_line}
    fi

    # 1. 狀態重設
    if [[ "$current_line" != "$_chs_last_result" || "$cursor_pos" != "$_chs_last_pos" ]]; then
        _chs_orig_line="$current_line"
        _chs_orig_prefix="${current_line:0:cursor_pos}"
        _chs_orig_suffix="${current_line:cursor_pos}"
        _chs_index=0

        # 強制完全同步
        history -a; history -c; history -r

        _chs_match_list=()
        # 修正後的 awk：先收集，後倒序去重輸出
        mapfile -t _chs_match_list < <(HISTTIMEFORMAT= history 5000 | awk -v orig="$_chs_orig_line" -v pref="$_chs_orig_prefix" -v suff="$_chs_orig_suffix" '
            {
                # 移除行首行號 (取代 sed)
                sub(/^[ ]*[0-9]+[ ]+/, "");
                if ($0 == "" || $0 == orig) next;
                lines[count++] = $0; # 先存入陣列
            }
            END {
                # 從最後一筆 (最新) 開始往前輸出
                for (i = count - 1; i >= 0; i--) {
                    cmd = lines[i];
                    if (seen[cmd]++) continue; # 確保只留下最新的一筆

                    # 檢查匹配
                    is_match = 0;
                    if (suff != "") {
                        if (index(cmd, pref) == 1 && substr(cmd, length(cmd)-length(suff)+1) == suff) is_match = 1;
                    } else {
                        if (index(cmd, pref) == 1) is_match = 1;
                    }

                    if (is_match) print cmd;
                    else all_fallback[all_count++] = cmd;
                }

                # 如果沒有精確匹配且是行尾搜尋，輸出全歷史 (Fallback)
                if (match_count == 0 && count > 0 && suff == "") {
                    # 注意：上面的 print 已經輸出了結果，這裡 awk 變數處理需小心
                    # 為了結構清晰，這裡簡化處理：
                }
            }')

        # 修正 Fallback：如果 match_list 為空，則重新抓取一次去重後的倒序歷史
        if [[ ${#_chs_match_list[@]} -eq 0 && -z "$_chs_orig_suffix" ]]; then
             mapfile -t _chs_match_list < <(HISTTIMEFORMAT= history 5000 | awk -v orig="$_chs_orig_line" '
                { sub(/^[ ]*[0-9]+[ ]+/, ""); if ($0 != "" && $0 != orig) lines[count++] = $0; }
                END { for (i = count - 1; i >= 0; i--) { if (!seen[lines[i]]++) print lines[i]; } }')
        fi
    fi

    local match_count=${#_chs_match_list[@]}

    # 2. 索引遍歷 (Up/Down)
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

    # 3. 套用結果
    if [[ $match_count -gt 0 ]]; then
        local selected="${_chs_match_list[$((_chs_index - 1))]}"
        READLINE_LINE="$selected"
        if [[ -z "$_chs_orig_suffix" ]]; then
            READLINE_POINT=${#selected}
        else
            READLINE_POINT=${#_chs_orig_prefix}
        fi

        # 不要在此處用 history -s，這會干擾當前的搜尋循環
        # 讓指令透過 Enter 執行後由系統自然寫入即可

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
