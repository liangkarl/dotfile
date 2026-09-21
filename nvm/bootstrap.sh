# NVM
#
# NVM: Node Version Manager
# NPM: Node Package Manager
# Node: JavaScript runtime environment
#
# Installation:
# nvm -> node -> npm
#

# Please note that upstream has asked us to make explicit managing
# nvm via Homebrew is unsupported by them and you should check any
# problems against the standard nvm install method prior to reporting.

# You should create NVM's working directory if it doesn't exist:
# mkdir ~/.nvm

# installed with brew
export NVM_DIR="${XDG_CONFIG_HOME}/nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && . "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && . "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"

# You can set $NVM_DIR to any location, but leaving it unchanged from
# /home/linuxbrew/.linuxbrew/Cellar/nvm/0.40.7 will destroy any nvm-installed Node installations
# upon upgrade/reinstall.
