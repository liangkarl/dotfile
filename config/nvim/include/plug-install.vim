call plug#begin('~/.config/nvim/plugged')

""
"  Primary Editor Function
""
" Start Screen:
" - nvim-dashboard: bad screen layout with lots of unused functions.
Plug 'mhinz/vim-startify'

" Statusline/ Bufferline:
" vim-airline: poor performance
" lightline: much better than vim-airline, but use VimL
Plug 'nvim-lualine/lualine.nvim'
Plug 'akinsho/bufferline.nvim'

" File Explorer:
" NerdTree: good, but use VimL
Plug 'kyazdani42/nvim-tree.lua'

" Operation Hint
" vim-which-key: old version with much complicated setup
Plug 'folke/which-key.nvim'     " display shortcut-mapping functions

" Autocompletion (without LSP source)
" coc: easy and powerful, but much complicated to customization
Plug 'hrsh7th/nvim-cmp'         " primary autocomplete function
Plug 'onsails/lspkind.nvim'     " adjust scroll menu width
Plug 'hrsh7th/cmp-buffer'       " snippet engine of buffer words

" Terminal
" vim-floaterm: fashion, but too complicated

" Fuzzy Search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary' }
let g:fuzzy_finder = 'clap'

""
"  Programming Function
""
" Language Support
Plug 'neovim/nvim-lspconfig'    " LSP configuration
Plug 'williamboman/mason.nvim'  " simplify the install of LSP
Plug 'm-pilia/vim-ccls'     " provide unique ccls function

" Source Code Format
Plug 'rhysd/vim-clang-format'   " format source code by clang-format
Plug 'editorconfig/editorconfig-vim'    " coding style file

" Syntax Highlight
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Lint
" ALE: slow performance

" Symbol Manager
" symbols-outline: only support LSP
" Vista: LSP function is problematic need Ctags support
Plug 'stevearc/aerial.nvim'
Plug 'nvim-lua/lsp-status.nvim'

" Autocompletion Comparision (LSP source)
Plug 'hrsh7th/cmp-nvim-lsp'     " snippet engine of LSP client
Plug 'saadparwaiz1/cmp_luasnip' " interface between nvim-cmp and LuaSnip
Plug 'L3MON4D3/LuaSnip'         " snippet engine for neovim written in Lua

""
"  Themes
""
Plug 'sainnhe/sonokai'
Plug 'marko-cerovac/material.nvim'
Plug 'sainnhe/gruvbox-material'
Plug 'navarasu/onedark.nvim'

""
"  Enhancements
""
Plug 'roxma/vim-tmux-clipboard' " share clipboard between tmux and vim
Plug 'andymass/vim-matchup'     " enhance '%' function, like if-endif
Plug 'markonm/traces.vim'       " enhance replace/search result,
                                "  previewing the last result.
Plug 'haya14busa/is.vim'        " make string search more convenient.
Plug 'osyo-manga/vim-anzu'      " show matched string number and total
Plug 'Krasjet/auto.pairs'       " enhance [/{/'..., auto balance pairs
Plug 'terryma/vim-expand-region'    " enhance visual mode, +/- to increase
                                    " or decrease selected visual range

" Cursor Movement
" vim_current_word: hard to setup blacklist and highlight style
Plug 'easymotion/vim-easymotion'    " move cursor location like vimium
Plug 'unblevable/quick-scope'   " enhance f & F functions, rendering
                                "  colors to index moving posisition in
                                "  a line

""
"  Debug Tools
""
"   vim-startuptime is a Vim plugin for viewing vim and nvim startup
" event timing information. The data is automatically obtained by
" launching (n)vim with the --startuptime argument. See
" :help startuptime-configuration for details on customization
" options.
" https://github.com/dstein64/vim-startuptime
Plug 'dstein64/vim-startuptime'

""
"  Git
""
" vim-gitgutter: poor performance in large project
Plug 'mhinz/vim-signify'        " show diff symbols aside via git diff
Plug 'liangkarl/tig-explorer.vim'   " use tig inside vim
Plug 'rbgrouleff/bclose.vim'    " needed by tig-explorer in Nvim config

""
"  Miscellaneous
""
Plug 'tpope/vim-commentary'     " comment codes easily
Plug 'tyru/open-browser.vim'    " open url from vim
Plug 'rmagatti/alternate-toggler'   " switch boolean value easily,
                                    "  true <-> false
Plug 'dhruvasagar/vim-table-mode'   " edit Markdown table easily
Plug 'arithran/vim-delete-hidden-buffers'   " delete hidden buffers
Plug 'ntpeters/vim-better-whitespace'       " show/remove trailing space

" NOTE:
" 1. Multiple cursor editing is fasion, but not sure of the benifits
" Plug 'terryma/vim-multiple-cursors'

" TODO:
" 1. improve tig-explorer.vim
"
" deprecated:
"
" Neomake is a plugin for Vim/Neovim to asynchronously run programs.
" Plug 'neomake/neomake'
"
" autocompletion seems better in clangd, instead of ccls
" Try to switch multi LSP in config
" xavierd/clang_complete

call plug#end()
