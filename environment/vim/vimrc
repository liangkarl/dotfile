"*****************************************************************************
"" Vundle Load
"*****************************************************************************
"{{{
" Load vundle
" no vi-compatible
set nocompatible

" Setting up Vundle - the vim plugin bundler
let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
if !filereadable(vundle_readme)
  echo "Installing Vundle..."
  echo ""
  silent !mkdir -p ~/.vim/bundle
  silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
  let iCanHazVundle=0
endif

" required for vundle
filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

"}}}


"*****************************************************************************
"" Vundle install packages
"*****************************************************************************
"{{{

" Python
Bundle 'fs111/pydoc.vim'
Bundle 'Soares/python.vim'
Bundle 'andviro/flake8-vim'

" Theme
Bundle 'avelino/flux.vim'
Bundle 'tomasr/molokai'
Bundle 'nelstrom/vim-mac-classic-theme'
Bundle 'mgutz/vim-colors'

" Text auto-completetion
Bundle 'Shougo/neocomplete.vim'

" Taglist like
Bundle 'majutsushi/tagbar'

" Git
Bundle 'tpope/vim-fugitive'
Bundle 'airblade/vim-gitgutter'

" Buf exp
Bundle 'jg/bufexplorer'

" Syntex
Bundle 'honza/vim-snippets'
Bundle 'scrooloose/syntastic'

" Others
Bundle 'Lokaltog/vim-powerline'
Bundle 'MarcWeber/vim-addon-mw-utils'
Bundle 'scrooloose/nerdcommenter'
Bundle 'tomtom/tlib_vim'

" cscope
Bundle 'vim-scripts/cecscope'

" Marks
Bundle 'vim-scripts/Marks-Browser'
Bundle 'vim-scripts/ShowMarks'
Bundle 'Yggdroot/vim-mark'

" files list
Bundle 'scrooloose/nerdtree'

" Installing plugins the first time
if iCanHazVundle == 0
  echo "Installing Bundles, please ignore key map error messages"
  echo ""
  :BundleInstall
endif

" allow plugins by file type
filetype plugin on
filetype indent on
"}}}


"*****************************************************************************
"                                Basic Setup
"*****************************************************************************
"{{{
" Unleash all VIM power
set nocompatible

" Fix backspace indent
set backspace=indent,eol,start

filetype on
filetype plugin indent on

" Better modes.  Remeber where we are, support yankring
set viminfo=!,'100,\"100,:20,<50,s10,h,n~/.viminfo

" Tabs. May be overriten by autocmd rules
set tabstop=4
set softtabstop=0
set shiftwidth=4
set expandtab

" Enable hidden buffers
set hidden

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Tab completion
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,.pyc,__pycache__

" Remember last location in file
if has("autocmd")
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
        \| exe "normal g'\"" | endif
endif

" GREP
set grepprg=ag

set encoding=utf-8
set fileencodings=utf-8
set bomb
set ttyfast
set binary

"Directories for swp files
set nobackup
set nowritebackup
set noswapfile

set sh=/bin/bash

set nocompatible
set fileformats=unix,dos,mac
set backspace=indent,eol,start
set showcmd

" Load cscope files
if has("cscope")
  set csprg=/usr/bin/cscope
  set csto=0
  set cst
  set nocsverb
  " add any database in current directory
  if filereadable("cscope.out")
    cs add cscope.out
  " else add database pointed to by environment
  elseif $CSCOPE_DB != ""
    cs add $CSCOPE_DB
  endif
  set csverb
endif

"}}}


"*****************************************************************************
"                              Visual Settigns
"*****************************************************************************
"{{{
" colorscheme, fonts, menus and etc
set background=dark
syntax on
set ruler
set number

" Menus I like :-)
" This must happen before the syntax system is enabled
" aunmenu Help.
" aunmenu Window.
" let no_buffers_menu=1
set mousemodel=popup
highlight BadWhitespace ctermbg=red guibg=red
colorscheme default
set t_Co=256
set cursorline
set guioptions=egmrt
set gfn=Monospace\ 8
if has("gui_running")
  if has("gui_mac") || has("gui_macvim")
    set guifont=Menlo:h12
    set transparency=7
  endif
else
  set term=xterm-256color
endif

" Disable the pydoc preview window for the omni completion
set completeopt-=preview

" Disable the blinking cursor.
set gcr=a:blinkon0
set scrolloff=3

" Status bar
set laststatus=2

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" load the plugin and indent settings for the detected filetype
filetype plugin indent on

" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

" Include user's local vim config
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\ %{fugitive#statusline()}

"}}}


"*****************************************************************************
"                               Abbreviations
"*****************************************************************************
"{{{
" no one is really happy until you have this shortcuts
cab W! w!
cab Q! q!
cab Wq wq
cab Wa wa
cab wQ wq
cab WQ wq
cab W w
cab Q q

"}}}


"*****************************************************************************
"                                 Variables
"*****************************************************************************
"{{{
" Conf Avelino
let g:snips_author = "Karl Liang"

" python support
" --------------
"  don't highlight exceptions and builtins. I love to override them in local
"  scopes and it sucks ass if it's highlighted then. And for exceptions I
"  don't really want to have different colors for my own exceptions ;-)
let python_highlight_all=1
let python_highlight_exceptions=0
let python_highlight_builtins=0

let html_no_rendering=1
let javascript_enable_domhtmlcss=1
let c_no_curly_error=1

" Powerline
let g:Powerline_symbols = 'compatible'

""""""""""""""""""""""""""""""
" showmarks setting
""""""""""""""""""""""""""""""
" Enable ShowMarks
let showmarks_enable = 1
" Show which marks
let showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
" Ignore help, quickfix, non-modifiable buffers
let showmarks_ignore_type = "hqm"
" Hilight lower & upper marks
let showmarks_hlline_lower = 1
let showmarks_hlline_upper = 1

""""""""""""""""""""""""""""""
" markbrowser setting
""""""""""""""""""""""""""""""
nmap <silent> <leader>mk :MarksBrowser<cr>

"}}}


"*****************************************************************************
"                                  Function
"*****************************************************************************
"{{{

function s:setupWrapping()
  set wrap
  set wm=2
  set textwidth=72
endfunction

function s:setupMarkup()
  call s:setupWrapping()
  noremap <buffer> <Leader>p :Mm <CR>
endfunction

" GUI Tab settings
function! GuiTabLabel()
    let label = ''
    let buflist = tabpagebuflist(v:lnum)
    if exists('t:title')
        let label .= t:title . ' '
    endif
    let label .= '[' . bufname(buflist[tabpagewinnr(v:lnum) - 1]) . ']'
    for bufnr in buflist
        if getbufvar(bufnr, '&modified')
            let label .= '+'
            break
        endif
    endfor
    return label
endfunction
set guitablabel=%{GuiTabLabel()}

" find files and populate the quickfix list
fun! FindFiles(filename)
  let error_file = tempname()
  silent exe '!find . -name "'.a:filename.'" | xargs file | sed "s/:/:1:/" > '.error_file
  set errorformat=%f:%l:%m
  exe "cfile ". error_file
  copen
  call delete(error_file)
endfun
command! -nargs=1 FindFile call FindFiles(<q-args>)

"}}}


"*****************************************************************************
"                               Autocmd Rules
"*****************************************************************************
"{{{
" Some minor or more generic autocmd rules
" The PC is fast enough, do syntax highlight syncing from start
autocmd BufEnter * :syntax sync fromstart
" Remember cursor position
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
" less comprez
autocmd BufNewFile,BufRead *.less set filetype=less

" txt
au BufRead,BufNewFile *.txt call s:setupWrapping()
" make use real tabs
au FileType make set noexpandtab


"********** Python
autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8
      \ formatoptions+=croq softtabstop=4 smartindent
      \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
autocmd FileType pyrex setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4
      \smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class,with
autocmd BufRead,BufNewFile *.py,*pyw set shiftwidth=4
autocmd BufRead,BufNewFile *.py,*.pyw set expandtab
autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
autocmd BufRead,BufNewFile *.py,*.pyw match BadWhitespace /^\t\+/
autocmd BufRead,BufNewFile *.py,*.pyw match BadWhitespace /\s\+$/
autocmd BufNewFile *.py,*.pyw set fileformat=unix
autocmd BufWritePre *.py,*.pyw normal m`:%s/\s\+$//e``
autocmd BufRead *.py,*.pyw set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufNewFile,BufRead *.py_tmpl,*.cover setlocal ft=python
" code completion
autocmd FileType python set omnifunc=pythoncomplete#Complete

"********** HTML
autocmd BufNewFile,BufRead *.mako,*.mak,*.jinja2 setlocal ft=html
autocmd FileType html,xhtml,xml,htmldjango,htmljinja,londonhtml,eruby,mako,haml,daml,css,tmpl setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2

"********** C/Obj-C/C++
autocmd FileType c setlocal tabstop=8 softtabstop=8 shiftwidth=8
autocmd FileType cpp setlocal tabstop=8 softtabstop=8 shiftwidth=8
autocmd FileType objc setlocal tabstop=8 softtabstop=8 shiftwidth=8

"********** vim
autocmd FileType vim setlocal expandtab shiftwidth=2 tabstop=8 softtabstop=2
autocmd FileType vim setlocal foldenable foldmethod=marker

"********** Javascript
autocmd FileType javascript setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd BufNewFile,BufRead *.json setlocal ft=javascript
" code completion
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS

"}}}


"*****************************************************************************
"                                  Mappings
"*****************************************************************************
"{{{

" Python Execution
noremap <C-K> :!python<CR>
noremap <C-L> :!python %<CR>

" Git
nnoremap <Leader>gc :Gcommit<CR>
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gd :Gvdiff<CR>
nnoremap <Leader>gb :Gblame<CR>

" Tag Code Navigation
nnoremap <Leader>l :TagbarToggle<CR>

" BufExplorer configuration
nnoremap <Leader>b :BufExplorer<cr>

" Vmap for maintain Visual Mode after shifting > and <
vnoremap < <gv
vnoremap > >gv

" Find file
noremap <Leader>\f :FindFile 
noremap <Leader>\x :close<CR>

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" ctags
nnoremap <Leader>[[ :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
nnoremap <Leader>[] g<c-]>

" cscope
nnoremap <Leader>]r :!/usr/bin/cscope -Rbq<CR>
nnoremap <Leader>]u :cs reset<CR>
nnoremap <Leader>]a :cs add <C-R>=expand("%:p:h") . "/"<CR><CR>
" find the caller of func, macro or enum
nnoremap <Leader>]s :CSL s <C-R>=expand("<cword>")<CR><CR>
" find definition of func, macro, enum
nnoremap <Leader>]g :CSL g <C-R>=expand("<cword>")<CR><CR>
nnoremap <Leader>]c :CSL c <C-R>=expand("<cword>")<CR><CR>
" find the string
nnoremap <Leader>]t :CSL t <C-R>=expand("<cword>")<CR><CR>
nnoremap <Leader>]e :CSL e <C-R>=expand("<cword>")<CR><CR>
" find the func include what funcs
nnoremap <Leader>]d :CSL d <C-R>=expand("<cword>")<CR><CR>

noremap z<Up> :wincmd k<CR>
noremap z<Down> :wincmd j<CR>
noremap z<Left> :wincmd h<CR>
noremap z<Right> :wincmd l<CR>

"}}}
