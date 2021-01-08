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
" | 3.1  | Vim Script       | Support Vim script codes             |
" | 3.2  | C/C++            | Support C/C++ codes                  |
" | 3.3  | Python           | Support Python codes                 |
" | 3.4  | Shell Script     | Support Shell script codes           |
" | 3.5  | Makefile         | Support Makefile syntex              |
" | 3.6  | Markdown         | Support Markdown syntex              |
" | 3.7  | HTML, XML        | Support HTML/XML syntex              |
" | 3.8  | Javascript       | Support Javascript codes             |
" |------+------------------+--------------------------------------|

""" 1. NeoVim Environment Setup

" 1.1 Environment Setup
" Display key-binding menu
Plug 'liuchengxu/vim-which-key'
" Show start screen
Plug 'mhinz/vim-startify'
" Theme
Plug 'morhetz/gruvbox'
" Show status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Function manager
Plug 'liuchengxu/vista.vim'
" git support
Plug 'airblade/vim-gitgutter'
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
Plug 'dense-analysis/ale'

""" 2. General Editor Tools

" 2.1 Text Format
" Open different lang file with their own coding style
Plug 'editorconfig/editorconfig-vim'

" 2.2 Display
" Show bookmark codes near by line number
Plug 'kshenoy/vim-signature'
" Highlit current words
Plug 'dominikduda/vim_current_word'
" Show trailing space
Plug 'ntpeters/vim-better-whitespace'
" Enhance '%' matchup function, like if-endif, etc
Plug 'andymass/vim-matchup'

" 2.3 Text Operation
" Preview replace/pattern/range result
Plug 'markonm/traces.vim'
" Improve display effect of searching text
Plug 'haya14busa/is.vim'
Plug 'osyo-manga/vim-anzu'

" 2.4 Edit
" Expand or reduce visual block region
Plug 'terryma/vim-expand-region'
" Comment codes easily
Plug 'tpope/vim-commentary'
" Auto-balance pairs
Plug 'Krasjet/auto.pairs'
" Draw text-styled table easily
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
" xavierd/clang_complete
" Clang-format
Plug 'rhysd/vim-clang-format'
" C/C++ syntex highlight
" ps. integrated with coc-clangd
Plug 'jackguo380/vim-lsp-cxx-highlight'
"
" dense-analysis/ale
call plug#end()
