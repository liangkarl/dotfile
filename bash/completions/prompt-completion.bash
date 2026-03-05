# ------------------------------------------------------------------------------
# Context-Aware History Search (V19 - Smooth Performance)
# ------------------------------------------------------------------------------

_context_history_search() {
    local direction=$1
    local current_line="$READLINE_LINE"
    local cursor_pos="$READLINE_POINT"

    # 1. 狀態重設與效能優化：只有在新搜尋開始時才讀取歷史
    if [[ "$current_line" != "$_chs_last_result" || "$cursor_pos" != "$_chs_last_pos" ]]; then
        _chs_orig_line="$current_line"
        _chs_orig_prefix="${current_line:0:cursor_pos}"
        _chs_orig_suffix="${current_line:cursor_pos}"
        _chs_index=0
        
        # 僅在開始搜尋時同步一次歷史
        history -a; history -c; history -r
        
        # 將歷史清單快取到變數中，避免連按時重複執行昂貴的 Pipe 操作
        # 排除掉最初輸入的那一行
        _chs_cache=$(history | sed 's/^[ ]*[0-9]*[ ]*//' | \
                     grep -v "^$(printf '%s' "$_chs_orig_line" | sed 's/[].[^$\\*]/\\&/g')$" | \
                     tac | awk '!seen[$0]++')
    fi

    local prefix="$_chs_orig_prefix"
    local suffix="$_chs_orig_suffix"
    local escaped_prefix=$(printf '%s' "$prefix" | sed 's/[].[^$\\*]/\\&/g')
    local escaped_suffix=$(printf '%s' "$suffix" | sed 's/[].[^$\\*]/\\&/g')

    # 2. 從快取中過濾結果 (這步現在極快)
    local matches=""
    if [[ -n "$suffix" ]]; then
        matches=$(echo "$_chs_cache" | grep "^${escaped_prefix}.*${escaped_suffix}$")
    else
        matches=$(echo "$_chs_cache" | grep "^${escaped_prefix}")
        [[ -z "$matches" ]] && matches="$_chs_cache"
    fi

    local match_count=$(echo "$matches" | grep -c .)
    
    # 3. 索引計算
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

    # 4. 套用結果
    if [[ $match_count -gt 0 ]]; then
        local selected=$(echo "$matches" | sed -n "${_chs_index}p")
        if [[ -n "$selected" ]]; then
            READLINE_LINE="$selected"
            if [[ -z "$suffix" ]]; then
                READLINE_POINT=${#selected}
            else
                READLINE_POINT=${#prefix}
            fi
            _chs_last_result="$selected"
            _chs_last_pos="$READLINE_POINT"
        fi
    fi
}

# 輔助函數與綁定 (移除 Debug Log 以換取最高速)
_chs_up() { _context_history_search "up"; }
_chs_down() { _context_history_search "down"; }

bind -r "\e[A" 2>/dev/null; bind -r "\eOA" 2>/dev/null
bind -r "\e[B" 2>/dev/null; bind -r "\eOB" 2>/dev/null
bind -x '"\e[A": _chs_up'; bind -x '"\eOA": _chs_up'
bind -x '"\e[B": _chs_down'; bind -x '"\eOB": _chs_down'
