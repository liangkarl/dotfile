# Default command to use when input is tty
# Now fzf (w/o pipe) will use fd instead of find
export FZF_DEFAULT_COMMAND='fd --type f'

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"