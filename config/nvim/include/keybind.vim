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
" TODO: conflict wiht buffer motion
noremap <Leader>p "*p
noremap <Leader>Y "+y
noremap <Leader>P "+p

" buffer motion (buffer: define as file content itself)
nnoremap <Leader>n :bn<CR>
nnoremap <Leader>p :bp<CR>
nnoremap <Leader>bb :b#<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>d :bd<CR>

" Window motion (window: view point of a buffer)
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l
nnoremap <Leader>q :close<CR>

" Tab motion (tab: a collection of windows, like workspace)

" vim-better-whitespace
" Strip whitespace
" <Leader>s: strip white space in whole file
" <Leader>sip: remove trailing whitespace from the current paragraph.
nnoremap <Leader>ss :StripWhitespace<CR>

" Plugin: vim-anzu
" nmap n <Plug>(anzu-n-with-echo)
" nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)

" Plugin: is.vim - incremental search improved
map n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)
map N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)

" Plugin: fzf
nnoremap <Leader>fb :FzfBuffers<CR>
nnoremap <Leader>ff :FzfFiles<CR>
" Recently open file
nnoremap <Leader>fr :FzfHistory<CR>
" Search history
nnoremap <Leader>fs :FzfHistory/<CR>
nnoremap <Leader>fc :FzfCommands<CR>
nnoremap <Leader>f? :FzfMaps<CR>
" List bookmarks
" |---------+-------------------------|
" | command | explain                 |
" |---------+-------------------------|
" | mx      | add/remove bookmark 'x' |
" | 'mx     | jump to bookmark 'x'    |
" |---------+-------------------------|
nnoremap <Leader>fm :FzfMarks<CR>

" Plugin: coc-explorer
nmap <space>ed :CocCommand explorer --preset .vim<CR>
nmap <space>ef :CocCommand explorer --preset floating<CR>
nmap <space>el :CocList explPresets

" Plugin: vim-table-mode
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

" Plugin: Commentary
" Toggle comment
nnoremap <Leader>gc :Commentary<CR>
