" Overview of which map command works in which mode.  More details below.
" |:-------------------------:+:----------------------------------------:|
" | CMD                       | MODES~                                   |
" |---------------------------+------------------------------------------|
" | :map, :noremap, :unmap    | Normal, Visual, Select, Operator-pending |
" | :nmap, :nnoremap, :nunmap | Normal                                   |
" | :vmap, :vnoremap, :vunmap | Visual and  Select                       |
" | :smap, :snoremap, :sunmap | Select                                   |
" | :xmap, :xnoremap, :xunmap | Visual                                   |
" | :omap, :onoremap, :ounmap | Operator-pending                         |
" | :map!, :noremap!, :unmap! | Insert and Command-line                  |
" | :imap, :inoremap, :iunmap | Insert                                   |
" | :lmap, :lnoremap, :lunmap | Insert, Command-line,  Lang-Arg          |
" | :cmap, :cnoremap, :cunmap | Command-line                             |
" | :tmap, :tnoremap, :tunmap | Terminal                                 |
" |---------------------------+------------------------------------------|

" map Leader
let mapleader = ' '

" Reload vim config
nnoremap <Leader>r :so $MYVIMRC<CR>

" CTRL-C: Quit insert mode, go back to Normal mode. Do not check for
" abbreviations. Does not trigger the InsertLeave autocommand event.
" Swap ESC & C-c
noremap! <C-[> <C-c>
noremap! <C-c> <ESC>

" Insert mode motion
inoremap <A-h> <Left>
inoremap <A-j> <Down>
inoremap <A-k> <Up>
inoremap <A-l> <Right>
inoremap <A-b> <C-Left>
inoremap <A-w> <C-Right>

" Open terminal
" PS. you can use the terminal as debug console
nnoremap <Leader>c :split term://bash<CR>:startinsert<CR>
" To use `ALT+{h,j,k,l}` to navigate windows from any mode:
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
" To map <Esc> to exit terminal-mode:
tnoremap <Esc> <C-\><C-n>

" Add keybind for system clipboard.
" There are two different clipboards for Linux and only one for Win
" |--------+--------------------------------------------------|
" | SYMBOL | Explain                                          |
" |:------:+--------------------------------------------------|
" |    *   | Use PRIMARY; Star is Select (for copy-on-select) |
" |    +   | Use CLIPBOARD; <C-c> (for the common keybind)    |
" |--------+--------------------------------------------------|
noremap <Leader><Space>y "*y
noremap <Leader><Space>p "*p
noremap <Leader><Space>c "+y
noremap <Leader><Space>v "+p

" buffer motion (buffer: define as file content itself)
nnoremap <Leader>n :bn<CR>
nnoremap <Leader>p :bp<CR>
nnoremap <Leader>bb :b#<CR>
nnoremap <Leader>w :w<CR>
" Save buffer content if modifiable is 'on'
nnoremap <Leader>d :if !&modifiable<CR>bd!<CR>else<CR>bd<CR>endif<CR><CR>

" Window motion (window: view point of a buffer)
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l
" quick command :C, only closing the current window, rather than quits.
command! -nargs=0 C :close
nnoremap <Leader>q :C<CR>

" Tab motion (tab: a collection of windows, like workspace)

" vim-better-whitespace
" Remove trailing whitespace
nnoremap <Leader>ss :StripWhitespace<CR>

" Plugin: vim-anzu
" nmap n <Plug>(anzu-n-with-echo)
" nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)

" Plugin: is.vim - incremental search improved
map n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)
map N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)

" Plugin: Vista.vim
nnoremap <Leader>= :Vista!!<CR>

" Plugin: fzf
nnoremap <Leader>fb :FzfBuffers<CR>
" Recently open file
nnoremap <Leader>fr :FzfHistory<CR>
" Search history
nnoremap <Leader>fs :FzfHistory/<CR>
nnoremap <Leader>fc :FzfCommands<CR>
nnoremap <Leader>f? :FzfMaps<CR>
" List bookmarks
" |----------+----------------------|
" | ORIG CMD | explain              |
" |----------+----------------------|
" | mx       | toggle bookmark 'x'  |
" | 'mx      | jump to bookmark 'x' |
" |----------+----------------------|
nnoremap <Leader>fm :FzfMarks<CR>

" Plugin: vim-table-mode
" |----------+----------------|
" | ORIG CMD |     explain    |
" |----------+:--------------:|
" | del col  |   <Leader>tdc  |
" | ins col  |   <Leader>tic  |
" | tableize | Tableize/[sep] |
" |----------+----------------|
nnoremap <Leader>tt :TableModeToggle<CR>
" Realigned text-table
nnoremap <Leader>tr :TableModeRealign<CR>
" Tableize
noremap <Leader>tz :Tableize/,

" Plugin: Commentary
" Toggle comment
noremap <Leader>gg :Commentary<CR>

" Plugin: coc
" Use <Tab> and <S-Tab> to navigate the completion list:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" Use <cr> to confirm completion
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Plugin: coc-explorer
" |-----+--------------------------|
" | CMD | explain                  |
" |-----+--------------------------|
" | d   | delete                   |
" | r   | rename                   |
" | a   | create file              |
" | A   | create folder            |
" |-----+--------------------------|
" | o   | toggle expand/collapse   |
" | q   | quit explore             |
" | R   | refresh explore          |
" | <BS>| goto parent dir          |
" | .   | Toggle hidden            |
" | *   | select                   |
" |-----+--------------------------|
nmap <space>en :CocCommand explorer --preset .nvim<CR>
nmap <space>ef :CocCommand explorer --preset floating<CR>
nmap <space>ee :CocCommand explorer --preset leftsideBar<CR>
nmap <space>el :CocList explPresets<CR>

" Plugin: coc-clangd
" Resolve symbol info under the cursor
" map <Leader>ci :CocCommand clangd.symbolInfo<CR>
" Switch between source/header files
" map <Leader>cs :CocCommand clangd.switchSourceHeader<CR>
