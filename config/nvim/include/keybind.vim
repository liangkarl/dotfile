" Overview of which map command works in which mode.  More details below.
" |----------+-----------+---------+------------------------------------------|
" | COMMANDS                       | MODES~                                   |
" |----------+-----------+---------+------------------------------------------|
" | :map     | :noremap  | :uumap  | Normal, Visual, Select, Operator-pending |
" | :nmap    | :nnoremap | :nunmap | Normal                                   |
" | :vmap    | :vnoremap | :vunmap | Visual and  Select                       |
" | :smap    | :snoremap | :sunmap | Select                                   |
" | :xmap    | :xnoremap | :xunmap | Visual                                   |
" | :omap    | :onoremap | :ounmap | Operator-pending                         |
" | :map!    | :noremap! | :unmap! | Insert and Command-line                  |
" | :imap    | :inoremap | :iunmap | Insert                                   |
" | :lmap    | :lnoremap | :lunmap | Insert, Command-line,  Lang-Arg          |
" | :cmap    | :cnoremap | :cunmap | Command-line                             |
" |----------+-----------+---------+------------------------------------------|

" map Leader
let mapleader = ' '

" Reload vim config
nnoremap <Leader>r :so $MYVIMRC<CR>

" CTRL-C: Quit insert mode, go back to Normal mode. Do not check for
" abbreviations. Does not trigger the InsertLeave autocommand event.
" Swap ESC & C-c
noremap! <C-[> <C-c>
noremap! <C-c> <ESC>

" Add keybind for system clipboard.
" There are two different clipboards for Linux and only one for Win
" '*' uses PRIMARY; mnemonic: Star is Select (for copy-on-select)
" '+' uses CLIPBOARD; mnemonic: CTRL PLUS C (for the common keybind)
noremap <Leader>y "*y
noremap <Leader>p "*p
noremap <Leader>Y "+y
noremap <Leader>P "+p

" buffer motion (buffer: define as file content itself)
nnoremap <Leader>n :bn<CR>
nnoremap <Leader>p :bp<CR>
nnoremap <Leader>bb :b#<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>d :bd<CR>
"nnoremap <Leader>L :ls<CR> | Replace by fzf

" Window motion (window: view point of a buffer)
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l
nnoremap <Leader>q :close<CR>

" Tab motion (tab: a collection of windows, like workspace)

" autocomplete
" git support

" NERDTree
nnoremap <Leader>2 :NERDTreeToggle<CR>

" vim-signature
" mx: add/remove bookmark x
" 'x: move to bookmark x
" List bookmarks
" nnoremap <Leader>M m/ | Replace by fzf

" vim-better-whitespace
" Strip whitespace
" <Leader>s: strip white space in whole file
" <Leader>sip: remove trailing whitespace from the current paragraph.
nnoremap <Leader>ss :StripWhitespace<CR>

" Plugin : vim-anzu
" nmap n <Plug>(anzu-n-with-echo)
" nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)
"nmap <Esc><Esc> <Plug>(anzu-clear-search-status)

" Plugin : is.vim - incremental search improved
" map n <Plug>(is-nohl)<Plug>(anzu-mode-n)
" map N <Plug>(is-nohl)<Plug>(anzu-mode-N)
map n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)
map N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)

" Plugin : fzf
nnoremap <Leader>fb :FzfBuffers<CR>
nnoremap <Leader>fw :FzfWindows<CR>
nnoremap <Leader>ff :FzfHistory<CR>
nnoremap <Leader>f; :FzfHistory:<CR>
nnoremap <Leader>f/ :FzfHistory/<CR>
nnoremap <Leader>fc :FzfCommands<CR>
nnoremap <Leader>f? :FzfMaps<CR>
nnoremap <Leader>fm :FzfMarks<CR>

" Plugin : vim-table-mode
" Example:
"|----------+----------------|
"| commands |     explain    |
"|----------+:--------------:|
"| del col  |   <Leader>tdc  |
"| ins col  |   <Leader>tic  |
"| tableize | Tableize/[sep] |
"|----------+----------------|
nnoremap <Leader>tm :TableModeToggle<CR>
" Realigned text-table
nnoremap <Leader>tr :TableModeRealign<CR>

" Plugin : Commentary
" Toggle comment
nnoremap <Leader>gc :Commentary<CR>

"
