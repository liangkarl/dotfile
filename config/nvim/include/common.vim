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

function! ToggleQuickFix()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
        copen
    else
        cclose
    endif
endfunction
nnoremap <silent> <space>tq :call ToggleQuickFix()<cr>

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

" Tab motion (tab: a collection of windows, like workspace)
"
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

