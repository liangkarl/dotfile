# ==============================================================================
# Context-Aware History Search for Bash (V20)
# ==============================================================================

_context_history_search() {
    local direction=$1
    local current_line="$READLINE_LINE"
    local cursor_pos="$READLINE_POINT"

    # 1. 狀態重設與快取建立 (效能優化核心)
    # 只有當使用者手動修改內容或移動游標時，才重新同步歷史並建立快照
    if [[ "$current_line" != "$_chs_last_result" || "$cursor_pos" != "$_chs_last_pos" ]]; then
        _chs_orig_line="$current_line"
        _chs_orig_prefix="${current_line:0:cursor_pos}"
        _chs_orig_suffix="${current_line:cursor_pos}"
        _chs_index=0

        # 同步當前 Session 歷史並讀取
        history -a; history -c; history -r

        # 建立去重快照 (限制最近 5000 筆以確保極致速度)
        # 排除掉最初輸入的那一行，避免搜尋到自己
        _chs_cache=$(history 5000 | sed 's/^[ ]*[0-9]*[ ]*//' | \
                     grep -v "^$(printf '%s' "$_chs_orig_line" | sed 's/[].[^$\\*]/\\&/g')$" | \
                     tac | awk '!seen[$0]++')
    fi

    local prefix="$_chs_orig_prefix"
    local suffix="$_chs_orig_suffix"
    local escaped_prefix=$(printf '%s' "$prefix" | sed 's/[].[^$\\*]/\\&/g')
    local escaped_suffix=$(printf '%s' "$suffix" | sed 's/[].[^$\\*]/\\&/g')

    # 2. 搜尋邏輯
    local matches=""
    if [[ -n "$suffix" ]]; then
        # 場景 A: 行中模式 (鎖定 prefix...suffix)
        matches=$(echo "$_chs_cache" | grep "^${escaped_prefix}.*${escaped_suffix}$")
    else
        # 場景 B: 行尾模式 (優先匹配 prefix...)
        matches=$(echo "$_chs_cache" | grep "^${escaped_prefix}")

        # 場景 C: Fallback (行尾找不到匹配時，顯示所有歷史)
        [[ -z "$matches" ]] && matches="$_chs_cache"
    fi

    local match_count=$(echo "$matches" | grep -c .)

    # 3. 索引計算與「回歸初始行」邏輯
    if [[ "$direction" == "up" ]]; then
        ((_chs_index++))
        [[ $_chs_index -gt $match_count ]] && _chs_index=$match_count
    else
        ((_chs_index--))
        # 如果 Down 過頭，回到最初輸入的狀態
        if [[ $_chs_index -lt 1 ]]; then
            READLINE_LINE="$_chs_orig_line"
            READLINE_POINT=${#_chs_orig_prefix}
            _chs_last_result="$_chs_orig_line"
            _chs_last_pos="$READLINE_POINT"
            _chs_index=0
            return
        fi
    fi

    # 4. 套用結果與維持模式
    if [[ $match_count -gt 0 ]]; then
        local selected=$(echo "$matches" | sed -n "${_chs_index}p")
        if [[ -n "$selected" ]]; then
            READLINE_LINE="$selected"

            # 關鍵：根據搜尋模式動態更新游標，確保連按時模式不跳掉
            if [[ -z "$suffix" ]]; then
                READLINE_POINT=${#selected}
            else
                READLINE_POINT=${#prefix}
            fi

            # 存下這次結果狀態，以便下次按鍵比對
            _chs_last_result="$selected"
            _chs_last_pos="$READLINE_POINT"
        fi
    fi
}

# 輔助 Function
_chs_up() { _context_history_search "up"; }
_chs_down() { _context_history_search "down"; }

# 5. 強制綁定 (先解除 Readline 原生攔截，確保 Script 每次都能執行)
bind -r "\e[A" 2>/dev/null; bind -r "\eOA" 2>/dev/null
bind -r "\e[B" 2>/dev/null; bind -r "\eOB" 2>/dev/null

bind -x '"\e[A": _chs_up'
bind -x '"\eOA": _chs_up'
bind -x '"\e[B": _chs_down'
bind -x '"\eOB": _chs_down'

# 移除 Debug Log，提升反應速度
# ==============================================================================
