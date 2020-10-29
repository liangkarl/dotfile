" map Leader
let mapleader = " "

" Reload vim config
nnoremap <Leader>r :so $MYVIMRC<CR>

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
" mx: add bookmark x
" dmx: remove bookmark x
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
"|  center  |          right |
"|:--------:+---------------:|
"| commands |        explain |
"|----------+----------------|
"| del col  | <Leader>tdc    |
"| ins col  | <Leader>tic    |
"| tableize | Tableize/[sep] |
"|----------+----------------|
nnoremap <Leader>tm :TableModeToggle<CR>
" Realigned text-table
nnoremap <Leader>tr :TableModeRealign<CR>

" Plugin : Commentary
" Toggle comment
nnoremap <Leader>gc :Commentary<CR>
