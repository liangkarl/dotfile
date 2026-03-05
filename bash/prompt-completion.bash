# ==============================================================================
# Context-Aware History Search - Extreme Performance (V21)
# ==============================================================================

_context_history_search() {
    local direction=$1
    local current_line="$READLINE_LINE"
    local cursor_pos="$READLINE_POINT"

    # 1. 狀態重設與快取建立 (效能核心：只在必要時更新)
    if [[ "$current_line" != "$_chs_last_result" || "$cursor_pos" != "$_chs_last_pos" ]]; then
        _chs_orig_line="$current_line"
        _chs_orig_prefix="${current_line:0:cursor_pos}"
        _chs_orig_suffix="${current_line:cursor_pos}"
        _chs_index=0

        # 同步 Session 歷史
        history -a; history -c; history -r

        # 高效處理歷史清單：使用 awk 一次性完成去編號、反轉與去重
        # 限制 3000 筆，這是兼顧搜尋深度與反應速度的黃金比例
        local escaped_orig=$(printf '%s' "$_chs_orig_line" | sed 's/[].[^$\\*]/\\&/g')
        _chs_cache=$(history 5000 | awk -v orig="$_chs_orig_line" '
            {
                # 移除前方的行號
                sub(/^[ ]*[0-9]+[ ]*/, "");
                # 排除目前這一行，並利用陣列去重，最後按順序存儲
                if ($0 != orig && !seen[$0]++) {
                    line[count++] = $0
                }
            }
            END {
                # 倒序輸出 (tac 的效果)
                for (i=count-1; i>=0; i--) print line[i]
            }')
    fi

    # 2. 建立搜尋正則
    local prefix="$_chs_orig_prefix"
    local suffix="$_chs_orig_suffix"
    local escaped_p=$(printf '%s' "$prefix" | sed 's/[].[^$\\*]/\\&/g')
    local escaped_s=$(printf '%s' "$suffix" | sed 's/[].[^$\\*]/\\&/g')

    # 3. 執行搜尋
    local matches=""
    if [[ -n "$suffix" ]]; then
        matches=$(printf '%s\n' "$_chs_cache" | grep "^${escaped_p}.*${escaped_s}$")
    else
        matches=$(printf '%s\n' "$_chs_cache" | grep "^${escaped_p}")
        [[ -z "$matches" ]] && matches="$_chs_cache"
    fi

    # 取得匹配總數 (使用 Bash 內建方式計數以提速)
    local match_list=()
    mapfile -t match_list <<< "$matches"
    local match_count=${#match_list[@]}
    [[ $match_count -eq 1 && -z "${match_list[0]}" ]] && match_count=0

    # 4. 索引計算
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

    # 5. 套用選中結果
    if [[ $match_count -gt 0 ]]; then
        local selected="${match_list[$((_chs_index - 1))]}"
        if [[ -n "$selected" ]]; then
            READLINE_LINE="$selected"
            # 游標位置更新
            [[ -z "$suffix" ]] && READLINE_POINT=${#selected} || READLINE_POINT=${#prefix}

            _chs_last_result="$selected"
            _chs_last_pos="$READLINE_POINT"
        fi
    fi
}

# 輔助 Function 與強制綁定
_chs_up() { _context_history_search "up"; }
_chs_down() { _context_history_search "down"; }

# 清除預設綁定並強制注入
bind -r "\e[A" 2>/dev/null; bind -r "\eOA" 2>/dev/null
bind -r "\e[B" 2>/dev/null; bind -r "\eOB" 2>/dev/null
bind -x '"\e[A": _chs_up'; bind -x '"\eOA": _chs_up'
bind -x '"\e[B": _chs_down'; bind -x '"\eOB": _chs_down'
