call plug#begin('~/.config/nvim/plugged')

" |------+------------------+--------------------------------------|
" | Item | Name             | Explain                              |
" |------+------------------+--------------------------------------|
" | 1    | Enviromnent      | Whole nvim setup                     |
" | 1.1  | Env Setup        | Set up enviroments                   |
" | 2    | Editor           | Funcions for editor                  |
" | 2.1  | Text Format      | Space, indent, tab, ...              |
" | 2.2  | Display          | More display effect                  |
" | 2.3  | Text Operation   | Search, replace, pattern, ...        |
" | 2.4  | Edit             | Improve edit efficiency              |
" | 2.5  | Others           | Others feature                       |
" | 3    | Language Support | Support languages                    |
" |------+------------------+--------------------------------------|

""" 1. NeoVim Environment Setup

" 1.1 Environment Setup
" |-------------------+------------------------------------|
" | Plug              | Desc                               |
" |-------------------+------------------------------------|
" | vim-which-key     | Display key-binding menu           |
" | vim-startify      | Show start screen                  |
" | gruvbox           | Theme                              |
" | lightline, ...    | Show status line                   |
" | vista.vim         | Function manager                   |
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
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'liuchengxu/vista.vim'
Plug 'mhinz/vim-signify'
Plug 'rbgrouleff/bclose.vim'
Plug 'iberianpig/tig-explorer.vim'
Plug 'arithran/vim-delete-hidden-buffers'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'roxma/vim-tmux-clipboard'

""" 2. General Editor Tools

" 2.1 Text Format
" |------------------+-----------------------------------------------------|
" | Plug             | Desc                                                |
" |------------------+-----------------------------------------------------|
" | editorconfig-vim | Open specific lang file with their own coding style |
" |------------------+-----------------------------------------------------|
Plug 'editorconfig/editorconfig-vim'

" 2.2 Display
" |-----------------------+------------------------------------------------|
" | Plug                  | Desc                                           |
" |-----------------------+------------------------------------------------|
" | vim-markbar           | Show bookmarks. PS. vim-signature is too slow  |
" | vim-better-whitespace | Show trailing space                            |
" | vim-matchup           | Enhance '%' matchup, like if-endif, etc        |
" | quick-scope           | To improve 'move' efficiency by highlight char |
" |-----------------------+------------------------------------------------|
" NOTE:
" vim_current_word is hard to setup blacklist and highlight style
Plug 'Yilin-Yang/vim-markbar'
Plug 'ntpeters/vim-better-whitespace'
Plug 'andymass/vim-matchup'
Plug 'unblevable/quick-scope'

" 2.3 Text Operation
" |------------------+------------------------------------------|
" | Plug             | Desc                                     |
" |------------------+------------------------------------------|
" | traces.vim       | Preview replace/pattern/range result     |
" | is.vim, vim-anzu | Improve display effect of searching text |
" |------------------+------------------------------------------|
Plug 'markonm/traces.vim'
Plug 'haya14busa/is.vim'
Plug 'osyo-manga/vim-anzu'

" 2.4 Edit
" |------------------+--------------------------------------|
" | Plug             | Desc                                 |
" |------------------+--------------------------------------|
" | vim-exp...region | Expand or reduce visual block region |
" | vim-commentary   | Comment codes easily                 |
" | auto.pairs       | Auto-balance pairs                   |
" | vim-table-mode   | Draw text-styled table easily        |
" |------------------+--------------------------------------|
" NOTE:
" Multiple cursor editing is fasion, but not sure of the benifits
" Plug 'terryma/vim-multiple-cursors'
Plug 'terryma/vim-expand-region'
Plug 'tpope/vim-commentary'
Plug 'Krasjet/auto.pairs'
Plug 'dhruvasagar/vim-table-mode'

" 2.5 Others
" |--------------+---------------------------------|
" | Plug         | Desc                            |
" |--------------+---------------------------------|
" | open-browser | Open URL from vim               |
" | vim-floaterm | Open terminal with float window |
" |--------------+---------------------------------|
Plug 'tyru/open-browser.vim'
Plug 'voldikss/vim-floaterm'

""" 3. Language Support

" 3.2 C/C++
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
