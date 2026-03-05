# ------------------------------------------------------------------------------
# Context-Aware History Search (V18 - The Loop Breaker)
# ------------------------------------------------------------------------------

_CHS_DEBUG_LOG="/tmp/chs_debug.log"

_context_history_search() {
    local direction=$1
    local current_line="$READLINE_LINE"
    local cursor_pos="$READLINE_POINT"

    echo ">>> [$(date +%T)] $direction | Line: '$current_line' | Pos: $cursor_pos" >> "$_CHS_DEBUG_LOG"

    # 1. 狀態重設與初始備份
    # 如果是全新的搜尋（不是連按上下），備份使用者最初輸入的內容
    if [[ "$current_line" != "$_chs_last_result" || "$cursor_pos" != "$_chs_last_pos" ]]; then
        echo "Reset: New Search Session." >> "$_CHS_DEBUG_LOG"
        _chs_orig_line="$current_line"
        _chs_orig_prefix="${current_line:0:cursor_pos}"
        _chs_orig_suffix="${current_line:cursor_pos}"
        _chs_index=0
        history -a; history -c; history -r
    fi

    local prefix="$_chs_orig_prefix"
    local suffix="$_chs_orig_suffix"
    local escaped_prefix=$(printf '%s' "$prefix" | sed 's/[].[^$\\*]/\\&/g')
    local escaped_suffix=$(printf '%s' "$suffix" | sed 's/[].[^$\\*]/\\&/g')

    # 2. 獲取去重歷史 (排除掉最初輸入的那一行)
    local history_list
    history_list=$(history | sed 's/^[ ]*[0-9]*[ ]*//' | grep -v "^$(printf '%s' "$_chs_orig_line" | sed 's/[].[^$\\*]/\\&/g')$" | tac | awk '!seen[$0]++')

    # 3. 搜尋匹配項
    local matches=""
    if [[ -n "$suffix" ]]; then
        matches=$(echo "$history_list" | grep "^${escaped_prefix}.*${escaped_suffix}$")
    else
        matches=$(echo "$history_list" | grep "^${escaped_prefix}")
        # Fallback
        if [[ -z "$matches" ]]; then
            echo "Fallback to general" >> "$_CHS_DEBUG_LOG"
            matches="$history_list"
        fi
    fi

    local match_count=$(echo "$matches" | grep -c .)
    
    # 4. 索引計算與「回到初始行」邏輯
    if [[ "$direction" == "up" ]]; then
        _chs_index=$((_chs_index + 1))
        [[ $_chs_index -gt $match_count ]] && _chs_index=$match_count
    else
        _chs_index=$((_chs_index - 1))
        # 如果按下低於 1，代表要回到最初輸入的樣子
        if [[ $_chs_index -lt 1 ]]; then
            echo "Returning to original input." >> "$_CHS_DEBUG_LOG"
            READLINE_LINE="$_chs_orig_line"
            READLINE_POINT=${#_chs_orig_prefix}
            _chs_last_result="$_chs_orig_line"
            _chs_last_pos="$READLINE_POINT"
            _chs_index=0
            return
        fi
    fi

    # 5. 套用選中結果
    if [[ $match_count -gt 0 ]]; then
        local selected=$(echo "$matches" | sed -n "${_chs_index}p")
        if [[ -n "$selected" ]]; then
            READLINE_LINE="$selected"
            # 維持游標
            if [[ -z "$suffix" ]]; then
                READLINE_POINT=${#selected}
            else
                READLINE_POINT=${#prefix}
            fi
            _chs_last_result="$selected"
            _chs_last_pos="$READLINE_POINT"
            echo "Selected: '$selected' ($_chs_index/$match_count)" >> "$_CHS_DEBUG_LOG"
        fi
    fi
}

_chs_up() { _context_history_search "up"; }
_chs_down() { _context_history_search "down"; }

# 解除並重綁
bind -r "\e[A" 2>/dev/null; bind -r "\eOA" 2>/dev/null
bind -r "\e[B" 2>/dev/null; bind -r "\eOB" 2>/dev/null
bind -x '"\e[A": _chs_up'; bind -x '"\eOA": _chs_up'
bind -x '"\e[B": _chs_down'; bind -x '"\eOB": _chs_down'
