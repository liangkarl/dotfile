call plug#begin('~/.config/nvim/plugged')

" |------+------------------+--------------------------------------|
" | Item | Name             | Explain                              |
" |------+------------------+--------------------------------------|
" | 1    | Enviromnent      | Whole nvim setup                     |
" | 1.1  | Integrated Tools | Tools like IDE providing many things |
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
" File explorer (and dependecy)
" Plug 'preservim/nerdtree'
" Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'kristijanhusak/defx-icons'
" Many icons / fonts for coc-explorer
" Plug 'ryanoasis/nerd-fonts'
" Plug 'ryanoasis/vim-devicons'

" 1.2 Integrated Tools
" Denite is a dark powered plugin for Neovim/Vim to unite all interfaces.
" Only for nvim
" Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }

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
" Search tool (for opening files)
" Grep keywords in Vim
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" 2.4 Edit
" Expand or reduce visual block region
Plug 'terryma/vim-expand-region'
" Comment codes easily
"Plug 'vim-scripts/The-NERD-Commenter'
Plug 'tpope/vim-commentary'
" Auto-balance pairs
Plug 'Krasjet/auto.pairs'
" Draw text-styled table easily
Plug 'dhruvasagar/vim-table-mode'
" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" 2.5 Others
" Open URL from vim
Plug 'tyru/open-browser.vim'

""" 3. Language Support
" 3.1 VIM script
" Popup vim build-in function signature
" Plug 'rbtnn/vim-popup_signature'

" 3.2 C/C++
" xavierd/clang_complete
" Clang-format
Plug 'rhysd/vim-clang-format'
"
" dense-analysis/ale
call plug#end()
