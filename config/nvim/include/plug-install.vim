call plug#begin('~/.config/nvim/plugged')

""" 1. NeoVim Environment Setup """
" |-------------------+------------------------------------|
" | Plug              | Desc                               |
" |-------------------+------------------------------------|
" | which-key         | Display key-binding menu           |
" | dashboard-nvim    | Show start screen                  |
" | lightline, ...    | Show status line                   |
" | vim-signify       | Show git diff by side              |
" | tig-explorer      | Show tig inside vim                |
" | bclose.vim        | Used for tig-explorer.vim          |
" | vim-del...buffers | Delete hidden buffers              |
" | fzf, fzf.vim      | Fuzzy searching and other features |
" | vim-tmux-clip...  | Share clipboard between tmux, vim  |
" | symbols-outline   | Function manager, like tagbar      |
" | nvim-lspconfig    | LSP config for nvim                |
" | nvim-tree         | File explorer                      |
" |-------------------+------------------------------------|
" NOTE:
" vim-airline has poor performance
" vim-gitgutter has poor performance
" Neomake is a plugin for Vim/Neovim to asynchronously run programs.
" Plug 'neomake/neomake'
Plug 'folke/which-key.nvim'
Plug 'glepnir/dashboard-nvim'
Plug 'mhinz/vim-signify'
Plug 'liangkarl/tig-explorer.vim'
Plug 'arithran/vim-delete-hidden-buffers'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Build the extra binary if cargo exists on your system.
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary' }
Plug 'roxma/vim-tmux-clipboard'
Plug 'neovim/nvim-lspconfig'
Plug 'kyazdani42/nvim-tree.lua'

" auto completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip' ""-- Snippets source for nvim-cmp
Plug 'L3MON4D3/LuaSnip' ""-- Snippets plugin

""" 2. Themes """
Plug 'sainnhe/sonokai'
Plug 'marko-cerovac/material.nvim'
Plug 'sainnhe/gruvbox-material'
Plug 'navarasu/onedark.nvim'

""" 3. General Editor Tools """
" |-----------------------+-----------------------------------------------------|
" | Plug                  | Desc                                                |
" |-----------------------+-----------------------------------------------------|
" | editorconfig-vim      | Open specific lang file with their own coding style |
" | vim-better-whitespace | Show trailing space                                 |
" | vim-matchup           | Enhance '%' matchup, like if-endif, etc             |
" | quick-scope           | To improve 'move' efficiency by highlight char      |
" | traces.vim            | Preview replace/pattern/range result                |
" | is.vim, vim-anzu      | Improve display effect of searching text            |
" | vim-exp...region      | Expand or reduce visual block region                |
" | vim-commentary        | Comment codes easily                                |
" | auto.pairs            | Auto-balance pairs                                  |
" | vim-table-mode        | Draw text-styled table easily                       |
" | alter...-toggler      | switch boolean value, true <-> false                |
" | open-browser          | Open URL from vim                                   |
" | nvim-toggle-terminal  | Open terminal with float window                     |
" |-----------------------+-----------------------------------------------------|
" NOTE:
" vim_current_word is hard to setup blacklist and highlight style
" 1. Multiple cursor editing is fasion, but not sure of the benifits
" Plug 'terryma/vim-multiple-cursors'
" 2. alternate-toggler is for nvim 0.5.0 or newer version
" Though floaterm is fashion, it's too complicated for me
" Plug 'voldikss/vim-floaterm'
Plug 'editorconfig/editorconfig-vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'andymass/vim-matchup'
Plug 'unblevable/quick-scope'
Plug 'markonm/traces.vim'
Plug 'haya14busa/is.vim'
Plug 'osyo-manga/vim-anzu'
Plug 'terryma/vim-expand-region'
Plug 'tpope/vim-commentary'
Plug 'Krasjet/auto.pairs'
Plug 'dhruvasagar/vim-table-mode'
Plug 'rmagatti/alternate-toggler'
Plug 'tyru/open-browser.vim'

""" 4. Language Support (LSP) """
" |------------------+------------------------------|
" | Plug             | Desc                         |
" |------------------+------------------------------|
" | vim-clang-format | format codes by clang-format |
" | nvim-treesitter  | syntex highlight tools       |
" | vim-ccls         | Provide uniq 'ccls' features |
" |------------------+------------------------------|
" TODO:
" autocompletion seems better in clangd, instead of ccls
" Try to switch multi LSP in config
" coc-clangd
" xavierd/clang_complete
" NOTE:
" Though dense-analysis/ale is really slow, it's an important plugin
" dense-analysis/ale
" We recommend updating the parsers on update
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

""" Deprecated """
" https://github.com/stevearc/aerial.nvim
Plug 'simrat39/symbols-outline.nvim'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'rbgrouleff/bclose.vim'
Plug 'rhysd/vim-clang-format'
Plug 'm-pilia/vim-ccls'
Plug 'caenrique/nvim-toggle-terminal'

call plug#end()
