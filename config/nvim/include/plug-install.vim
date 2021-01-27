call plug#begin('~/.config/nvim/plugged')

" |------+------------------+--------------------------------------|
" | Item | Name             | Explain                              |
" |------+------------------+--------------------------------------|
" | 1    | Enviromnent      | Whole nvim setup                     |
" | 1.1  | Env Setup        | Set up enviroments                   |
" | 1.2  | Integrated Tools | Tools like IDE providing many things |
" |------+------------------+--------------------------------------|
" | 2    | Editor           | Funcions for editor                  |
" | 2.1  | Text Format      | Space, indent, tab, ...              |
" | 2.2  | Display          | More display effect                  |
" | 2.3  | Text Operation   | Search, replace, pattern, ...        |
" | 2.4  | Edit             | Improve edit efficiency              |
" | 2.5  | Others           | Others feature                       |
" |------+------------------+--------------------------------------|
" | 3    | Language Support | Support languages                    |
" |------+------------------+--------------------------------------|

""" 1. NeoVim Environment Setup

" 1.1 Environment Setup
" |-------------------+--------------------------|
" | Plug              | Desc                     |
" |-------------------+--------------------------|
" | vim-which-key     | Display key-binding menu |
" | vim-startify      | Show start screen        |
" | gruvbox           | Theme                    |
" | lightline, ...    | Show status line         |
" | vista.vim         | Function manager         |
" | vim-signify       | Show git diff by side    |
" | vim-del...buffers | Delete hidden buffers    |
" |-------------------+--------------------------|
Plug 'liuchengxu/vim-which-key'
Plug 'mhinz/vim-startify'
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'liuchengxu/vista.vim'
Plug 'mhinz/vim-signify'
Plug 'arithran/vim-delete-hidden-buffers'
" NOTE: vim-airline is too slow
" NOTE: vim-gitgutter is too slow
" Neomake is a plugin for Vim/Neovim to asynchronously run programs.
" Plug 'neomake/neomake'
" File explorer (and dependecy)
" Use coc-explorer instead

" 1.2 Integrated Tools
" Searching is fzf's main function
" Provide buffer, window, keymap and etc functions
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Autocompletion is coc's main function
" Like Fzf, coc provide many features
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Autocompletion supporting LSP
" mainly construct by vim script instead of python
" Plug 'dense-analysis/ale'

""" 2. General Editor Tools

" 2.1 Text Format
" Open different lang file with their own coding style
Plug 'editorconfig/editorconfig-vim'

" 2.2 Display
" |-----------------------+------------------------------------------------|
" | Plug                  | Desc                                           |
" |-----------------------+------------------------------------------------|
" | vim-markbar           | Show bookmarks. PS. vim-signature is too slow  |
" | vim_current_word      | Highlit current words                          |
" | vim-better-whitespace | Show trailing space                            |
" | vim-matchup           | Enhance '%' matchup, like if-endif, etc        |
" | quick-scope           | To improve 'move' efficiency by highlight char |
" |-----------------------+------------------------------------------------|
Plug 'Yilin-Yang/vim-markbar'
Plug 'dominikduda/vim_current_word'
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
Plug 'terryma/vim-expand-region'
Plug 'tpope/vim-commentary'
Plug 'Krasjet/auto.pairs'
Plug 'dhruvasagar/vim-table-mode'
" Multiple Edit
" Plug 'terryma/vim-multiple-cursors'

" 2.5 Others
" Open URL from vim
Plug 'tyru/open-browser.vim'
" Open terminal with float window
Plug 'voldikss/vim-floaterm'

""" 3. Language Support

" 3.1 VIM script
" Supported by coc-vimlsp

" 3.2 C/C++
" |-------------------+------------------------------|
" | Plug              | Desc                         |
" |-------------------+------------------------------|
" | vim-clang-format  | format codes by clang-format |
" | vim-...-highlight | C/C++ syntex highlight       |
" | vim-ccls          | Provide uniq 'ccls' features |
" |-------------------+------------------------------|
Plug 'rhysd/vim-clang-format'
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'm-pilia/vim-ccls'
" ps. integrated with coc-clangd
" xavierd/clang_complete
" dense-analysis/ale

call plug#end()
