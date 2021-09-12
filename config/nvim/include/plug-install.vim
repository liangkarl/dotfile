call plug#begin('~/.config/nvim/plugged')

""" 1. NeoVim Environment Setup """
" |-------------------+------------------------------------|
" | Plug              | Desc                               |
" |-------------------+------------------------------------|
" | vim-which-key     | Display key-binding menu           |
" | vim-startify      | Show start screen                  |
" | lightline, ...    | Show status line                   |
" | vim-signify       | Show git diff by side              |
" | tig-explorer      | Show tig inside vim                |
" | bclose.vim        | Used for tig-explorer.vim          |
" | vim-del...buffers | Delete hidden buffers              |
" | fzf, fzf.vim      | Fuzzy searching and other features |
" | coc.nvim          | LSP clients and lots of features   |
" | vim-tmux-clip...  | Share clipboard between tmux, vim  |
" |-------------------+------------------------------------|
" NOTE:
" vim-airline has poor performance
" vim-gitgutter has poor performance
" Neomake is a plugin for Vim/Neovim to asynchronously run programs.
" Plug 'neomake/neomake'
Plug 'liuchengxu/vim-which-key'
Plug 'mhinz/vim-startify'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'mhinz/vim-signify'
Plug 'rbgrouleff/bclose.vim'
Plug 'liangkarl/tig-explorer.vim'
Plug 'arithran/vim-delete-hidden-buffers'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'roxma/vim-tmux-clipboard'

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
" | vim-markbar           | Show bookmarks. PS. vim-signature is too slow       |
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
Plug 'Yilin-Yang/vim-markbar'
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
Plug 'caenrique/nvim-toggle-terminal'

""" 4. Language Support (LSP) """
" |-------------------+------------------------------|
" | Plug              | Desc                         |
" |-------------------+------------------------------|
" | vim-clang-format  | format codes by clang-format |
" | vim-...-highlight | C/C++ syntex highlight       |
" | vim-ccls          | Provide uniq 'ccls' features |
" |-------------------+------------------------------|
" TODO:
" autocompletion seems better in clangd, instead of ccls
" Try to switch multi LSP in config
" coc-clangd
" xavierd/clang_complete
" NOTE:
" Though dense-analysis/ale is really slow, it's an important plugin
" dense-analysis/ale
Plug 'rhysd/vim-clang-format'
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'm-pilia/vim-ccls'

call plug#end()
