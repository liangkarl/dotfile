# ==============================================================================
# Context-Aware History Search (V29 - Ultimate Performance)
# ==============================================================================

_context_history_search() {
    local direction=$1
    local current_line="$READLINE_LINE"
    local cursor_pos="$READLINE_POINT"

    # 1. 修正游標異常
    if [[ $cursor_pos -eq 0 && ${#current_line} -gt 0 ]]; then
        cursor_pos=${#current_line}
    fi

    # 2. 狀態重設與快取建立 (僅在搜尋條件改變時執行一次昂貴操作)
    if [[ "$current_line" != "$_chs_last_result" || "$cursor_pos" != "$_chs_last_pos" ]]; then
        _chs_orig_line="$current_line"
        _chs_orig_prefix="${current_line:0:cursor_pos}"
        _chs_orig_suffix="${current_line:cursor_pos}"
        _chs_index=0

        # 同步歷史
        history -a; history -r

        local rev_cmd="tac"
        [[ "$OSTYPE" == "darwin"* ]] && rev_cmd="tail -r"

        # 一次性處理：去行號、去重、過濾並存入陣列 (限 5000 筆)
        # 使用 Bash 的 mapfile 配合一次性的 awk 處理，效能最高
        _chs_match_list=()
        local escaped_p="${_chs_orig_prefix}"
        local escaped_s="${_chs_orig_suffix}"

        # 這裡利用 awk 的高效過濾能力，直接在建立快取時就完成 Prefix/Mid-line 比對
        mapfile -t _chs_match_list < <(history 5000 | $rev_cmd | sed -E 's/^[ ]*[0-9]+[ ]+//' | \
            awk -v orig="$_chs_orig_line" -v pref="$_chs_orig_prefix" -v suff="$_chs_orig_suffix" '
            {
                if ($0 == orig || $0 == "" || seen[$0]++) next;
                if (suff != "") {
                    # 行中模式：prefix.*suffix
                    if (index($0, pref) == 1 && substr($0, length($0)-length(suff)+1) == suff) print $0
                } else {
                    # 行尾/Prefix 模式
                    if (index($0, pref) == 1) print $0
                }
            }')

        # 如果 prefix 搜尋沒結果且是行尾模式，則載入全歷史作為 Fallback
        if [[ ${#_chs_match_list[@]} -eq 0 && -z "$_chs_orig_suffix" ]]; then
            mapfile -t _chs_match_list < <(history 5000 | $rev_cmd | sed -E 's/^[ ]*[0-9]+[ ]+//' | \
                awk -v orig="$_chs_orig_line" '{if ($0 != orig && $0 != "" && !seen[$0]++) print $0}')
        fi
    fi

    local match_count=${#_chs_match_list[@]}

    # 3. 索引遍歷 (純記憶體操作，極快)
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
            return
        fi
    fi

    # 4. 套用結果 (減少重繪)
    if [[ $match_count -gt 0 ]]; then
        local selected="${_chs_match_list[$((_chs_index - 1))]}"

        if [[ "$READLINE_LINE" != "$selected" ]]; then
            READLINE_LINE="$selected"
        fi

        # 更新游標位置
        if [[ -z "$_chs_orig_suffix" ]]; then
            READLINE_POINT=${#selected}
        else
            READLINE_POINT=${#_chs_orig_prefix}
        fi

        _chs_last_result="$selected"
        _chs_last_pos="$READLINE_POINT"
    fi
}

# 綁定與效能調優
_chs_up() { _context_history_search "up"; }
_chs_down() { _context_history_search "down"; }

bind -r "\e[A" 2>/dev/null; bind -r "\eOA" 2>/dev/null
bind -r "\e[B" 2>/dev/null; bind -r "\eOB" 2>/dev/null
bind -x '"\e[A": _chs_up'; bind -x '"\eOA": _chs_up'
bind -x '"\e[B": _chs_down'; bind -x '"\eOB": _chs_down'
