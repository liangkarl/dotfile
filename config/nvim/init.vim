source ~/.config/nvim/include/plug-install.vim
source ~/.config/nvim/include/plug-config.vim
source ~/.config/nvim/include/keybind.vim
source ~/.config/nvim/include/theme/material.vim
source ~/.config/nvim/include/theme/gruvbox-material.vim
source ~/.config/nvim/include/theme/onedark.vim
source ~/.config/nvim/include/theme/sonokai.vim

set number
" show the cursor position all the time
set ruler
" display incomplete commands
set showcmd
" Close a split window in Vim without resizing other windows
set noequalalways

" set no line number in terminal buffer
autocmd TermOpen * setlocal nonumber norelativenumber

" opening a new file when the current buffer has unsaved changes
" causes files to be hidden instead of closed
set hidden
" set cmdheight=2

" To show buffer name for lightline-bufferline config
set showtabline=2

" Set up font for special characters
set guifont=SauceCodePro\ Nerd\ Font\ Mono

set diffopt+=algorithm:histogram
" backup/swap/undo files
" set directory=~/.config/nvim/swap//,.,~/tmp,/var/tmp,/tmp
set noswapfile
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

set mouse=v " copy text without borders

if (has("termguicolors"))
  set termguicolors
endif

colorscheme material

hi cursorline cterm=underline ctermbg=NONE
hi cursorline gui=underline guibg=NONE guifg=BURLYWOOD
set cursorline
