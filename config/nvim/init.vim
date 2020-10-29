source ~/.config/nvim/include/plugin_install.vim
source ~/.config/nvim/include/plugin_config.vim
source ~/.config/nvim/include/keybinding.vim

set number
" show the cursor position all the time
set ruler
set cursorline
" display incomplete commands
set showcmd

" opening a new file when the current buffer has unsaved changes
" causes files to be hidden instead of closed
set hidden

" backup/swap/undo files
set directory=~/.config/nvim/swap//,.,~/tmp,/var/tmp,/tmp
set backupdir=~/.config/nvim/backup//,.,~/tmp,~/
set undodir=~/.config/nvim/undo//,.

set termencoding=utf-8
set encoding=utf-8
set fileencoding=utf-8

set colorcolumn=80

set noshowmode " hide default mode text (e.g. INSERT) as airline already displays it
set display+=lastline " don't show '@@@' when there is no enough room

colorscheme gruvbox
