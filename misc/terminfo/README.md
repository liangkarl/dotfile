# FAQ

## For MAC that don't support `tmux-256color`

```bash
# Compile terminfo for tmux-256color
tic -x tmux-256color tmux-256color.terminfo

# Optional: install terminfo for all users
sudo tic -x tmux-256color tmux-256color.terminfo

# Confirm the installation
infocmp -x tmux-256color
```

https://gist.github.com/nicm/ea9cf3c93f22e0246ec858122d9abea1
