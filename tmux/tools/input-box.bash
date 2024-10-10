#!/usr/bin/env bash

# basic information
session="$(tmux display-message -p '#S')"
window="$(tmux display-message -p '#W')"
client="$(tmux display-message -p '#{client_name}')"
pane="$(tmux display-message -p '#{pane_id}')"

# 建立臨時檔案
temp_file=$(mktemp)
end_sig=$(mktemp)

trap "rm -rf $temp_file" 0

# 在tmux的彈出窗口中讀取使用者輸入並儲存到臨時檔案
tmux display-popup -h10% -E "sh -c 'echo \"$*:\"; read cmd; echo \$cmd > $temp_file'" || touch $temp_file

# 等待使用者輸入完成
while [ ! -e "$temp_file" ]; do
    sleep 0.1
done

# 讀取使用者輸入
user_input=$(cat "$temp_file")

# 刪除臨時檔案
rm "$temp_file"

# 輸出使用者輸入
echo "$user_input"
