" Remember cursor position
fun! s:RestoreCursorPosition()
  " if last visited position is available
  if line("'\"") > 1 && line("'\"") <= line("$")
    " jump to the last position
    exe "normal! g'\""
  endif
endfun

let g:nvim_dir = expand('<sfile>:h/nvim')
let g:lua_dir = g:nvim_dir . '/lua'
let g:config_dir = g:nvim_dir . '/config'
let g:theme_dir = g:config_dir . '/theme'
let g:finder_dir = g:config_dir . '/finder'

source <sfile>:h/config.vim

" import plugin install
call plug#begin(g:nvim_dir . '/plugged')

" Prerequisite
Plug 'nvim-lua/plenary.nvim'      " Affect telescope
Plug 'neovim/nvim-lspconfig'      " LSP configuration
Plug 'williamboman/mason.nvim'    " Install LSP servers
Plug 'hrsh7th/nvim-cmp'           " Autocomplete framework
Plug 'rbgrouleff/bclose.vim'      " needed by tig-explorer in Nvim config

" Integration Development Environment
Plug 'mhinz/vim-startify'         " Start-up screen
Plug 'nvim-lualine/lualine.nvim'  " Status line (button)
Plug 'akinsho/bufferline.nvim'    " Buffer line (top)
Plug 'kyazdani42/nvim-tree.lua'   " File Explorer
Plug 'stevearc/aerial.nvim'       " Symbol Manager
Plug 'nvim-lua/lsp-status.nvim'
Plug 'folke/which-key.nvim'       " Display cheat sheet of vim shortcut
Plug 'ahmedkhalf/project.nvim'    " provides superior project management
Plug 'editorconfig/editorconfig-vim'  " setup indent, space, etc, look like

" Enhanced functions
Plug 'roxma/vim-tmux-clipboard' " share clipboard between tmux and vim
Plug 'Asheq/close-buffers.vim'  " delete buffers
Plug 'echasnovski/mini.nvim'    " A 'Swiss Army Knife' with many small features
Plug 'tpope/vim-commentary'     " comment codes easily
Plug 'tyru/open-browser.vim'    " open url from vim
Plug 'andymass/vim-matchup'     " enhance '%' function, like if-endif
Plug 'markonm/traces.vim'       " preview the replace/search result
Plug 'haya14busa/is.vim'        " make string search more convenient.
Plug 'Krasjet/auto.pairs'       " enhance [/{/'..., auto balance pairs
Plug 'unblevable/quick-scope'   " enhance f/F and rendering colors in a line
Plug 'easymotion/vim-easymotion'    " move cursor location like vimium
Plug 'rmagatti/alternate-toggler'   " switch boolean value easily,
Plug 'dhruvasagar/vim-table-mode'   " edit Markdown table easily
Plug 'terryma/vim-expand-region'    " text object selection with +/-
Plug 'ntpeters/vim-better-whitespace'   " show/remove trailing space
Plug 'nvim-treesitter/nvim-treesitter'  " Syntax highlight/lint with `treesitter`

" Formatter
Plug 'rhysd/vim-clang-format'   " format code with clang-format

" Autocompletion (without LSP source)
Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }    " AI assist for completion
Plug 'onsails/lspkind.nvim'     " adjust scroll menu width
Plug 'hrsh7th/cmp-buffer'       " snippet engine of buffer words

" Terminal

" Language Support
Plug 'm-pilia/vim-ccls'     " provide unique ccls function

" Autocompletion Comparision (LSP source)
Plug 'hrsh7th/cmp-nvim-lsp'     " snippet engine of LSP client
Plug 'saadparwaiz1/cmp_luasnip' " interface between nvim-cmp and LuaSnip
Plug 'L3MON4D3/LuaSnip'         " snippet engine for neovim written in Lua

" Debug Tools
Plug 'dstein64/vim-startuptime' " view startup event timing with `--startuptime`
Plug 'mfussenegger/nvim-dap'    " Debug Adapter Protocol client implementation

" Git
Plug 'mhinz/vim-signify'        " show diff symbols aside via git diff
Plug 'liangkarl/tig-explorer.vim'   " git blame whole file
Plug 'TimUntersberger/neogit'   " git status
Plug 'sindrets/diffview.nvim'   " git diff

" Fuzzy Search
if !empty(g:fuzzy_finder)
  if g:fuzzy_finder == 'fzf'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
  elseif g:fuzzy_finder == 'telescope'
    " when fzf was not usable
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
  endif

  exe 'source' g:finder_dir . '/' . g:fuzzy_finder . '.vim'
endif

"  Themes
if !empty(g:editor_theme)
  if g:editor_theme == 'sonokai'
    Plug 'sainnhe/sonokai'
  elseif g:editor_theme == 'material'
    Plug 'marko-cerovac/material.nvim'
  elseif g:editor_theme == 'gruvbox-material'
    Plug 'sainnhe/gruvbox-material'
  elseif g:editor_theme == 'onedark'
    Plug 'navarasu/onedark.nvim'
  endif

  exe 'source' g:theme_dir . '/' . g:editor_theme . '.vim'
endif

" NOTE:
" autocompletion seems better in clangd, instead of ccls
" Try to switch multi LSP in config
" xavierd/clang_complete

call plug#end()

exe 'colorscheme' g:editor_theme

" FIXME:
" There may be some error for reserved plugin.vim as they setup
" non-existed variables or functions.
" import plugin config
for f in split(glob(g:config_dir . '/*.vim'), '\n')
  exe 'source' f
endfor

" import common setup
exe 'source' g:nvim_dir . '/keybind.vim'

" import lua configs
for f in split(glob(g:lua_dir . '/config/*.lua'), '\n')
  exe 'luafile' f
endfor

" no one is really happy until you have this shortcuts
cab W! w!
cab Q! q!
cab Wa wa
cab Wq wq
cab wQ wq
cab WQ wq
cab W w
cab Q q

" allow plugins by file type
filetype plugin indent on

syntax on

" no vi-compatible
set nocompatible

" set wait time for combined keys
set timeoutlen=300

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

" Set Byte Order Mask(BOM) dealing with UTF8 in window
set bomb
" shorten the response time in tty
set ttyfast
" treat all files as binary to prevent from unexpected changes
set binary

set number
" show the cursor position all the time
set ruler
" display incomplete commands
set showcmd
" Close a split window in Vim without resizing other windows
set noequalalways

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

set cursorline

" for material only
hi CursorLine cterm=underline ctermbg=none gui=none guifg=BURLYWOOD guibg=#1c1c1c
hi Cursor guifg=none guibg=#7a4d4d

" Some minor or more generic autocmd rules

" The PC is fast enough, do syntax highlight syncing from start
autocmd BufEnter * :syntax sync fromstart

" A simple function to restore previous cursor position
autocmd BufReadPost * call s:RestoreCursorPosition()

" set no line number in terminal buffer
autocmd TermOpen * setlocal nonumber norelativenumber
