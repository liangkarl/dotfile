" Remember cursor position
fun! s:RestoreCursorPosition()
  " if last visited position is available
  if line("'\"") > 1 && line("'\"") <= line("$")
    " jump to the last position
    exe "normal! g'\""
  endif
endfun

fun! s:toggleEditMode(enable)
  " list: show 'listchars'
  " showbreak: set wrap line symbol
  " colorcolumn: set color column
  " FIXME: move trailing spaces function to somewhere else
  if a:enable
    set list showbreak=↪\  colorcolumn=80
    lua MiniTrailspace.highlight()
  else
    set nolist showbreak= colorcolumn=
    lua MiniTrailspace.unhighlight()
  endif
endfun

let g:nvim_dir = expand('<sfile>:h/nvim')
let g:lua_dir = g:nvim_dir . '/lua'
let g:config_dir = g:nvim_dir . '/config'
let g:theme_dir = g:config_dir . '/theme'
let g:finder_dir = g:config_dir . '/finder'

source <sfile>:h/config.vim

" import common setup
exe 'source' g:nvim_dir . '/keybind.vim'
exe 'luafile' g:nvim_dir . '/entry.lua'

" Misc settings:
" Filetype detection is enabled by default. This can be disabled by adding
"   ":filetype off" to |init.vim|.
" Syntax highlighting is enabled by default. This can be disabled by adding
"   ":syntax off" to |init.vim|.
" |man.lua| plugin is enabled, so |:Man| is available by default.
" |matchit| plugin is enabled. To disable it in your config: >
"   :let loaded_matchit = 1
let loaded_matchit = 1

" |g:vimsyn_embed| defaults to "l" to enable Lua highlighting

" allow plugins by file type
filetype plugin indent on

" set wait time for combined keys
set timeoutlen=300

" Fix backspace indent
set backspace=indent,eol,start

" Better modes.  Remeber where we are, support yankring
set shada=!,'100,\"100,:20,<50,s10,h,n~/.vim.shada

" Set the title text in the window
set title
set titlestring=%F

" Tab completion in command bar
set wildmode=full
set wildignore+=*.o,*.obj,.git,*.rbc,.pyc,__pycache__

" Set cursor pattern (no blink)
set guicursor=n-v-c-sm:block-nCursor,i-ci-ve:ver25-iCursor,r-cr-o:hor20-rCursor
highlight nCursor gui=NONE cterm=NONE ctermbg=1 guibg=SlateBlue
highlight iCursor gui=NONE cterm=NONE ctermbg=15 guibg=#ffffff
highlight rCursor gui=NONE cterm=NONE ctermbg=12 guibg=Red

" Keep cursor line centered only in Normal mode
autocmd! CursorMoved * set scrolloff=999
autocmd! InsertEnter * set scrolloff=5

" Symbols for non-charactors:
"   tab:→\ , space:·, nbsp:␣, trail:•, eol:¶, precedes:«, extends:»
set listchars=tab:→\ ,nbsp:␣,precedes:«,extends:»

autocmd! InsertLeave * call s:toggleEditMode(0)
autocmd! InsertEnter * call s:toggleEditMode(1)

" Use modeline overrides
set modeline
set modelines=10

" Set Byte Order Mask(BOM) dealing with UTF8 in window
set bomb
" treat all files as binary to prevent from unexpected changes
set binary

" show the line numbers with hybrid mode in the left side
set number relativenumber
" Close a split window in Vim without resizing other windows
set noequalalways

" Set up font for special characters
set guifont=SauceCodePro\ Nerd\ Font\ Mono

set diffopt+=algorithm:histogram

set nobackup
" When vim failed to write buffer, don't create backup-like file for it.
set nowritebackup
set noswapfile

" Don't show mode text(eg, INSERT) as lualine has already do it
set noshowmode

" Show unprintable characters hexadecimal as <xx> instead of using ^C and ~C.
set display+=uhex

" disable support mouse action in normal mode.
set mouse=vi

set termguicolors
set cursorline

" no one is really happy until you have this shortcuts
cab W! w!
cab Q! q!
cab Wa wa
cab Wq wq
cab wQ wq
cab WQ wq
cab W w
cab Q q

" The PC is fast enough, do syntax highlight syncing from start
autocmd! BufEnter * :syntax sync fromstart
" A simple function to restore previous cursor position
autocmd! BufReadPost * call s:RestoreCursorPosition()
" set no line number in terminal buffer
autocmd! TermOpen * setlocal nonumber norelativenumber
