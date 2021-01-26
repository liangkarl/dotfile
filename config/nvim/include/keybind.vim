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

" Reload vim config
nnoremap <silent><Leader>so :so $MYVIMRC<CR>
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
nnoremap <silent><F3> :FloatermToggle<CR>
tnoremap <silent><F3> <C-\><C-N>:FloatermToggle<CR>

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

" Plugin: Vista.vim
nnoremap <silent><F2> :Vista!!<CR>

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
nnoremap <silent><Leader>tg :TableModeToggle<CR>
" Realigned text-table
nnoremap <silent><Leader>tr :TableModeRealign<CR>
" Tableize
noremap <Leader>tz :Tableize/,

" Plugin: Commentary
" Toggle comment
noremap <silent><Leader>gg :Commentary<CR>

" Plugin: coc
" for debug coc LSP
nnoremap <Leader>o :CocCommand workspace.showOutput<CR>

" Use tab for trigger completion with characters ahead and navigate.
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Use <Tab> and <S-Tab> to navigate the completion list:
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" Use <cr> to confirm completion
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Symbol renaming.
nmap <silent><leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap <C-f> and <C-b> for scroll float windows/popups.
" Note coc#float#scroll works on neovim >= 0.4.0 or vim >= 8.2.0750
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

" NeoVim-only mapping for visual mode scroll
" Useful on signatureHelp after jump placeholder of snippet expansion
if has('nvim')
  vnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
  vnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
endif

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" gd will go by coc -> tags -> searchdecl
function! s:GoToDefinition()
  if CocAction('jumpDefinition')
    return v:true
  endif

  let ret = execute("silent! normal \<C-]>")
  if ret =~ "Error"
    call searchdecl(expand('<cword>'))
  endif
endfunction
nmap <silent> gd :call <SID>GoToDefinition()<CR>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

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
nmap <silent><space>en :CocCommand explorer --preset open.nvim<CR>
nmap <silent><space>ef :CocCommand explorer --preset center<CR>
nmap <silent><space>el :CocList explPresets<CR>

" Plugin: coc-clangd
" Resolve symbol info under the cursor
" map <Leader>ci :CocCommand clangd.symbolInfo<CR>
" Switch between source/header files
" map <Leader>cs :CocCommand clangd.switchSourceHeader<CR>
