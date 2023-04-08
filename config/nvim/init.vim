" FIXME:
" change the path to $XDG_CONFIG_HOME

" import plugin install
source ~/.config/nvim/plug-install.vim

" import common setup
source ~/.config/nvim/common.vim

" import plugin config
for f in split(glob('~/.config/nvim/config/*.vim'), '\n')
    exe 'source' f
endfor

" import theme setup
for f in split(glob('~/.config/nvim/theme/*.vim'), '\n')
    exe 'source' f
endfor

" import lua configs
luafile ~/.config/nvim/lua/init.lua
" TODO: import each lua plugin config instead of init.lua

" no vi-compatible
set nocompatible

" Fix backspace indent
set backspace=indent,eol,start

" Better modes.  Remeber where we are, support yankring
set viminfo=!,'100,\"100,:20,<50,s10,h,n~/.viminfo

" Set the title text in the window
set title
set titleold="Terminal"
set titlestring=%F

" Tab completion in command bar
set wildmode=full
set wildignore+=*.o,*.obj,.git,*.rbc,.pyc,__pycache__

" Set cursor pattern (no blink)
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
" Preserve how many lines before reaching top/botton of screen
set scrolloff=5

" Use modeline overrides
set modeline
set modelines=10

" Searching
set hlsearch
set incsearch

set bomb
set ttyfast
set binary

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

"Directories for swp files
set nobackup
set nowritebackup
set noswapfile

set termencoding=utf-8
set encoding=utf-8
set fileencodings=utf-8
set fileencoding=utf-8

set colorcolumn=80

set noshowmode " hide default mode text (e.g. INSERT) as airline already displays it
set display+=lastline " don't show '@@@' when there is no enough room

set mouse=v " copy text without borders

if (has("termguicolors"))
  set termguicolors
endif

colorscheme material

" for material only
hi CursorLine cterm=underline ctermbg=none gui=none guifg=BURLYWOOD guibg=#1c1c1c
hi Cursor guifg=none guibg=#7a4d4d

set cursorline
