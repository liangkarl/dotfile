# ==============================================================================
# Contextual History Search (CHS) - Production Version
# ==============================================================================
# 【過往坑點全紀錄】
# 坑點 1 (時間戳記污染): HISTTIMEFORMAT 會讓 history 多出日期，導致 awk 匹配錯誤。
#   -> 解法: 使用 `HISTTIMEFORMAT= history` 暫時遮蔽時間輸出。
# 坑點 2 (游標回傳異常): 在 Tmux 等環境下，READLINE_POINT 有時會錯回傳 0。
#   -> 解法: 透過 `if [[ $cursor_pos -eq 0 && ${#current_line} -gt 0 ]]` 手動校正。
# 坑點 3 (歷史未同步): 剛打完的指令還在記憶體，沒寫入檔案，導致搜尋不到。
#   -> 解法: 搜尋前執行 `history -a; history -c; history -r` 強制雙向同步。
# 坑點 4 (重複項過多): 歷史紀錄裡有無數個相同的指令，會讓搜尋體驗極差。
#   -> 解法: awk 內先存入陣列，END 區塊倒序輸出並使用 `seen[cmd]++` 去重。
# 坑點 5 (變數命名衝突): awk 內若使用 log 作為變數，會觸發 Fatal Error。
#   -> 解法: Debug 檔案路徑變數改名為 logf。
# 坑點 6 (殭屍快取 Zombie Cache): 如果在上一個 Prompt 放棄搜尋回到空行 (last_result="")，
#   執行新指令後，下一個空行按上，腳本會誤判 current_line("") == last_result("")，
#   導致跳過更新，抓到舊的歷史清單。
#   -> 解法: 額外加入 history 狀態判斷，只要最後一筆 history 變動，強制重新掃描。
# 坑點 7 (HISTCMD 不可靠): 在 bind -x / 某些互動環境下，HISTCMD 可能固定不變，
#   例如 debug 顯示多次按鍵都是 HISTCMD: 1，導致無法偵測新指令已經進入 history。
#   -> 解法: 不再使用 HISTCMD 作為 cache key，改用 `HISTTIMEFORMAT= history 1`
#      取得目前 Bash 記憶體中的最後一筆 history。
# ==============================================================================

# Debug 控制開關 (1: 開啟, 0: 關閉)
CHS_DEBUG=0
CHS_LOG_FILE="/tmp/chs_debug.log"

_context_history_search() {
    local direction=$1
    local current_line="$READLINE_LINE"
    local cursor_pos="$READLINE_POINT"

    # [修改原因]
    # HISTCMD 在 bind -x 或某些 shell 狀態下可能不會正常遞增。
    # 如果用 HISTCMD 判斷 history 是否變動，可能會誤用舊的 _chs_match_list。
    # 所以改用最後一筆 history 的實際內容作為 history 狀態指紋。
    local current_history_state
    current_history_state="$(HISTTIMEFORMAT= history 1)"

    # [Debug Print] 紀錄動作、游標位置與目前最後一筆 history 狀態
    if [[ "$CHS_DEBUG" -eq 1 ]]; then
        echo "[$(date +'%T')] ACT: $direction | POS: $cursor_pos | LINE: '$current_line' | HISTSTATE: '$current_history_state'" >> "$CHS_LOG_FILE"
    fi

    # 修正游標異常
    if [[ $cursor_pos -eq 0 && ${#current_line} -gt 0 ]]; then
        cursor_pos=${#current_line}
    fi

    # 1. 狀態重設
    # [修改原因]
    # 原本用 current_line / cursor_pos / HISTCMD 判斷是否重建搜尋結果。
    # 但 HISTCMD 可能固定不變，所以改成 current_history_state。
    # 這樣即使 current_line 仍是空字串，只要剛剛有執行新指令，也會重新掃描 history。
    if [[ "$current_line" != "$_chs_last_result" || "$cursor_pos" != "$_chs_last_pos" || "$current_history_state" != "$_chs_last_history_state" ]]; then
        _chs_orig_line="$current_line"
        _chs_orig_prefix="${current_line:0:cursor_pos}"
        _chs_orig_suffix="${current_line:cursor_pos}"
        _chs_index=0

        # 強制完全同步
        history -a; history -c; history -r

        # [修改原因]
        # history -a/-c/-r 之後，最後一筆 history 可能因重新讀入檔案而改變。
        # 所以同步後必須重新取得一次 history 狀態，作為新的 cache 基準點。
        _chs_last_history_state="$(HISTTIMEFORMAT= history 1)"

        _chs_match_list=()
        mapfile -t _chs_match_list < <(HISTTIMEFORMAT= history 5000 | awk \
            -v orig="$_chs_orig_line" \
            -v pref="$_chs_orig_prefix" \
            -v suff="$_chs_orig_suffix" \
            -v dbg="$CHS_DEBUG" \
            -v logf="$CHS_LOG_FILE" '
            {
                sub(/\r$/, ""); # Clear \r
                sub(/^[ \t]*[0-9]+[* \t]+/, ""); # Remove history number and optional star
                if ($0 == "" || $0 == orig) next;
                lines[count++] = $0;
            }
            END {
                for (i = count - 1; i >= 0; i--) {
                    cmd = lines[i];
                    if (seen[cmd]++) continue;

                    is_match = 0;
                    if (suff != "") {
                        if (index(cmd, pref) == 1 && substr(cmd, length(cmd)-length(suff)+1) == suff) is_match = 1;
                    } else {
                        if (index(cmd, pref) == 1) is_match = 1;
                    }

                    if (is_match) {
                        print cmd;
                        if (dbg == 1) print "  -> [MATCH]: " cmd >> logf;
                    }
                }
            }')

        # Fallback 邏輯
        if [[ ${#_chs_match_list[@]} -eq 0 && -z "$_chs_orig_suffix" ]]; then
             [[ "$CHS_DEBUG" -eq 1 ]] && echo "  -> [FALLBACK TRIGGERED]" >> "$CHS_LOG_FILE"
             mapfile -t _chs_match_list < <(HISTTIMEFORMAT= history 5000 | awk -v orig="$_chs_orig_line" '
                { sub(/\r$/, ""); sub(/^[ \t]*[0-9]+[* \t]+/, ""); if ($0 != "" && $0 != orig) lines[count++] = $0; }
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
            READLINE_LINE="$_chs_orig_line"
            READLINE_POINT=${#_chs_orig_prefix}
            _chs_last_result="$_chs_orig_line"
            _chs_last_pos="$READLINE_POINT"
            _chs_index=0
            [[ "$CHS_DEBUG" -eq 1 ]] && echo "  -> [RESET] Back to original input" >> "$CHS_LOG_FILE"
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

        _chs_last_result="$selected"
        _chs_last_pos="$READLINE_POINT"
        [[ "$CHS_DEBUG" -eq 1 ]] && echo "  -> [APPLY] Index $_chs_index/$match_count: '$selected'" >> "$CHS_LOG_FILE"
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
