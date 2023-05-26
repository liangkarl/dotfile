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

fun! ShowFileInfo()
  echo 'File Path:'
  echo expand('%:p')
  echo 'Current Working Directory:'
  echo getcwd()
endfun

fun! ChangeCWD()
  echo 'Change CWD:'
  lcd %:p:h
  echo getcwd()
endfun

" Prevent runtime error of function in use
silent! fun! ReloadConfig()
  source $MYVIMRC
  echo 'Reload nvim config:'
  echo $MYVIMRC
endfun

silent! fun! UpdateConfig()
  edit $MYVIMRC
  autocmd! BufDelete $MYVIMRC source $MYVIMRC | echo 'Reload: ' .. $MYVIMRC
endfun

fun! ToggleQuickFix()
  if empty(filter(getwininfo(), 'v:val.quickfix'))
    copen
  else
    cclose
  endif
endfun

" Save buffer content if modifiable is 'on'
silent! fun! CloseBuf()
  if !&modifiable
    silent! bdelete!
  else
    silent! bdelete
  endif
endfun

" map leader
let mapleader = ' '

" Retain the visual selection after indent lines
vnoremap > >gv
vnoremap < <gv

" Use "P" to put without yanking the deleted text into the unnamed register
" Replace 'p' with 'P' since the default keybind is too strange
vnoremap p P

" quit vim diff at once
if &diff
  nnoremap <silent><leader>q :qall<cr>
endif

" Reload vim config
nnoremap <silent><leader>so :call ReloadConfig()<cr>
nnoremap <silent><leader>pf :call UpdateConfig()<cr>
nnoremap <silent><leader>cf :call ShowFileInfo()<cr>
" Change the directory only for the current window
nnoremap <silent><leader>cd :call ChangeCWD()<cr>

" <C-c>: leave Insert Mode and return to Normal Mode.
"   The difference between <C-c> and <Esc> is as below:
"   1. Would not check abbreviations
"   2. Would not trigger `InsertLeave` event of autocommand.
" Swap ESC and <C-c>
noremap! <C-[> <C-c>
noremap! <C-c> <ESC>

nnoremap <silent><leader>qt :call ToggleQuickFix()<cr>

" Add keybind for system clipboard.
" There are two different clipboards for Linux and only one for Win
" |--------+--------------------------------------------------|
" | SYMBOL | Explain                                          |
" |:------:+--------------------------------------------------|
" |    *   | Use PRIMARY; Star is Select (for copy-on-select) |
" |    +   | Use CLIPBOARD; <C-c> (for the common keybind)    |
" |--------+--------------------------------------------------|
noremap <leader><space>y "*y
noremap <leader><space>p "*p
noremap <leader><space>c "+y
noremap <leader><space>v "+p

" Tab motion (tab: a collection of windows, like workspace)
"
" buffer motion (buffer: define as file content itself)
nnoremap <silent><leader>bb :b#<cr>
nnoremap <silent><leader>w :w<cr>

nnoremap <silent><leader>d :call CloseBuf()<cr>

" Window motion (window: view point of a buffer)
nnoremap <leader>pp <C-w>W
nnoremap <leader>nn <C-w>w

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <leader>e
noremap <leader>e :e <C-R>=expand("%:p:h") . "/"<cr>
noremap <leader>ec :e <C-R>=getcwd() . "/"<cr>

" string manipulation
" +1/-1 to the number
nnoremap <silent><leader>+ <C-a>
nnoremap <silent><leader>- <C-x>

" Toggle boolean
nnoremap <silent> <leader>! :ToggleAlternate<cr>

" Plugin: quick-scope
" pink: 2f/2F <x> => jump to pink char
" blue: f/F <x> => jump to blue char
nmap <leader>jt <plug>(QuickScopeToggle)
xmap <leader>jt <plug>(QuickScopeToggle)

" Plugin: tig-explorer
" open tig with current file
nnoremap <leader>tf :TigOpenCurrentFile<cr>
" open tig with Project root path
nnoremap <leader>td :TigOpenProjectRootDir<cr>
" open tig blame with current file
nnoremap <leader>tb :TigBlame<cr>

" Plugin: vim-better-whitespace
" Remove trailing whitespace
nnoremap <silent><leader>ss :StripWhitespace<cr>

" Plugin: vim-commentary
" Toggle comment
noremap <silent><leader>gg :Commentary<cr>

" Plugin: close-buffers.vim
" close several types of buffers
nnoremap <leader>bm :Bdelete menu<cr>
nnoremap <leader>bs :Bdelete select<cr>


" Plugin: vim-easymotion
"
" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
" nmap <leader>s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.

" https://github.com/easymotion/vim-easymotion
" meaning of symbols
" f2 => hit two chars
" f => hit one char
" w => move to the begin of word
" l => move to the begin of line
" sol => start of line
" eol => end of line
nmap <leader>jj <Plug>(easymotion-overwin-f2)

" Plugin: vim-table-mode
" |----------+----------------|
" | ORIG CMD |     explain    |
" |----------+:--------------:|
" | del col  |   <leader>tdc  |
" | ins col  |   <leader>tic  |
" | tableize | Tableize/[sep] |
" |----------+----------------|
nnoremap <silent><leader>tg :TableModeToggle<cr>
" Realigned text-table
nnoremap <silent><leader>tr :TableModeRealign<cr>
" Tableize
noremap <leader>tz :Tableize/,

if !empty(g:fuzzy_finder)
  if g:fuzzy_finder == 'fzf'
    " Plugin: fzf - fuzzy finder
    exe 'source' g:finder_dir . '/fzf.vim'
  elseif g:fuzzy_finder == 'telescope'
    " Plugin: telescope
    exe 'source' g:finder_dir . '/telescope.vim'
  endif
endif

