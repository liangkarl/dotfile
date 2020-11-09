source ~/.config/nvim/include/plug-install.vim
source ~/.config/nvim/include/plug-config.vim
source ~/.config/nvim/include/keybind.vim

set number
" show the cursor position all the time
set ruler
set cursorline
" display incomplete commands
set showcmd
" Close a split window in Vim without resizing other windows
set noequalalways

" opening a new file when the current buffer has unsaved changes
" causes files to be hidden instead of closed
set hidden

" Set up font for special characters
set guifont=SauceCodePro\ Nerd\ Font\ Mono

" backup/swap/undo files
set directory=~/.config/nvim/swap//,.,~/tmp,/var/tmp,/tmp
" Coc.nvim may get error if backup enabled
" set backupdir=~/.config/nvim/backup//,.,~/tmp,~/
set nobackup
set undodir=~/.config/nvim/undo//,.

set termencoding=utf-8
set encoding=utf-8
set fileencoding=utf-8

set colorcolumn=80

set noshowmode " hide default mode text (e.g. INSERT) as airline already displays it
set display+=lastline " don't show '@@@' when there is no enough room

colorscheme gruvbox
