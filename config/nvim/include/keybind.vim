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

" Retain the visual selection after indent lines
vnoremap > >gv
vnoremap < <gv

" map Leader
let mapleader = ' '

" FIXME: workaround for invisible cursor
" nnoremap <silent> <Leader>cu :set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
nnoremap <silent> <Leader>cu :set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20<CR>

" Reload vim config
nnoremap <Leader>so :so $MYVIMRC<CR>:echo "Reload nvim config"<CR>
nnoremap <Leader>cwf :echo expand('%:p')<CR>
nnoremap <Leader>cwd :pwd<CR>
" Change the directory only for the current window
nnoremap <Leader>cd :lcd %:p:h<CR>

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
nnoremap <silent> <C-z> :ToggleTerminal<Enter>
tnoremap <silent> <C-z> <C-\><C-n>:ToggleTerminal<Enter>

function! ToggleQuickFix()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
        copen
    else
        cclose
    endif
endfunction
nnoremap <silent> <space>tq :call ToggleQuickFix()<cr>

" To use `ALT+{h,j,k,l}` to navigate windows from any mode:
" tnoremap <A-h> <C-\><C-N><C-w>h
" tnoremap <A-j> <C-\><C-N><C-w>j
" tnoremap <A-k> <C-\><C-N><C-w>k
" tnoremap <A-l> <C-\><C-N><C-w>l
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

" vim-delete-hidden-buffers
nnoremap <Leader>bd :DeleteHiddenBuffers<CR>

" buffer motion (buffer: define as file content itself)
nnoremap <silent><Leader>n :bn<CR>
nnoremap <silent><Leader>p :bp<CR>
nnoremap <silent><Leader>bb :b#<CR>
nnoremap <silent><Leader>w :w<CR>
" Save buffer content if modifiable is 'on'
fun CloseBuf()
  if !&modifiable
    bdelete!
  else
    bdelete
  endif
endfun
nnoremap <Leader>d :call CloseBuf()<CR>

" Window motion (window: view point of a buffer)
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l

noremap <space>1 1<C-w>w
noremap <space>2 2<C-w>w
noremap <space>3 3<C-w>w
noremap <space>4 4<C-w>w
noremap <space>5 5<C-w>w

" quick command :C, only closing the current window, rather than quits.
command! -nargs=0 C :close
nnoremap <Leader>c :C<CR>

" Tab motion (tab: a collection of windows, like workspace)

" vim-better-whitespace
" Remove trailing whitespace
nnoremap <silent><Leader>ss :StripWhitespace<CR>

" Plugin: vim-anzu
" nmap n <Plug>(anzu-n-with-echo)
" nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)

" Plugin: is.vim - incremental search improved
map n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)
map N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)

" Plugin: quick-scope
nmap <leader>q <plug>(QuickScopeToggle)
xmap <leader>q <plug>(QuickScopeToggle)
let g:qs_buftype_blacklist = ['terminal', 'nofile']

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

" Plugin: tig-explorer
" open tig with current file
nnoremap <Leader>tf :TigOpenCurrentFile<CR>
" open tig with Project root path
nnoremap <Leader>td :TigOpenProjectRootDir<CR>
" open tig blame with current file
nnoremap <Leader>tb :TigBlame<CR>

" Plugin: vim-table-mode
" |----------+----------------|
" | ORIG CMD |     explain    |
" |----------+:--------------:|
" | del col  |   <Leader>tdc  |
" | ins col  |   <Leader>tic  |
" | tableize | Tableize/[sep] |
" |----------+----------------|
nnoremap <silent><Leader>tg :TableModeToggle<CR>
" Realigned text-table
nnoremap <silent><Leader>tr :TableModeRealign<CR>
" Tableize
noremap <Leader>tz :Tableize/,

" Plugin: vim-marker
nmap <Leader>mm <Plug>ToggleMarkbar
" the following are unneeded if ToggleMarkbar is mapped
nmap <Leader>mo <Plug>OpenMarkbar
nmap <Leader>mc <Plug>CloseMarkbar

" Plugin: Commentary
" Toggle comment
noremap <silent><Leader>gg :Commentary<CR>

" Plugin: alternate-toggler
" Toggle boolean
nnoremap <silent> <leader>vv :ToggleAlternate<CR>
