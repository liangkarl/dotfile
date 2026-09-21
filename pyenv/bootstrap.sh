# pyenv environment settings
export PYENV_ROOT="${HOME}/.pyenv"

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
