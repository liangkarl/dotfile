" Plugin: airline
" buffers at the top as tabs
let g:airline#extensions#tabline#enabled = 1
" choose tab line format style
let g:airline#extensions#tabline#formatter = 'unique_tail'
" show buffer number
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#show_tab_type=1
" enable powerline-fonts
let g:airline_powerline_fonts = 1

" Make line number human readable
function! MyLineNumber()
  return substitute(line('.'), '\d\@<=\(\(\d\{3\}\)\+\)$', ',&', 'g'). ' | '.
    \    substitute(line('$'), '\d\@<=\(\(\d\{3\}\)\+\)$', ',&', 'g')
endfunction

call airline#parts#define('linenr', {'function': 'MyLineNumber', 'accents': 'bold'})
let g:airline_section_z = airline#section#create(['%3p%%: ', 'linenr', ':%3v'])

" Add the window number in front of the mode
function! WindowNumber(...)
    let builder = a:1
    let context = a:2
    call builder.add_section('airline_b', ' %{tabpagewinnr(tabpagenr())} ')
    return 0
endfunction

call airline#add_statusline_func('WindowNumber')
call airline#add_inactive_statusline_func('WindowNumber')

" Plugin: Vista.vim
function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction
set statusline+=%{NearestMethodOrFunction()}

" By default vista.vim never run if you don't call it explicitly.
"
" If you want to show the nearest function in your statusline automatically,
" you can add the following line to your vimrc
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

" Ensure you have installed some decent font to show these pretty symbols, then you can enable icon for the kind.
let g:vista#renderer#enable_icon = 1

" The default icons can't be suitable for all the filetypes, you can extend it as you wish.
let g:vista#renderer#icons = {
\   "function": "\uf794",
\   "variable": "\uf71b",
\  }

" To enable fzf's preview window set g:vista_fzf_preview.
" The elements of g:vista_fzf_preview will be passed as arguments to fzf#vim#with_preview()
" For example:
let g:vista_fzf_preview = ['right:50%']

" Set executives
let g:vista#executives = ['coc']

" set up files
let g:vista_executive_for = {
\	'typescript': 'coc',
\	'javascript': 'coc',
\	'vim': 'coc',
\	'cpp': 'coc',
\	'c': 'coc',
\	'html': 'coc',
\	'css': 'coc',
\	'python': 'coc'
\  }

" let g:vista_icon_indent = ['╰─🞂 ', '├─🞂 ']
let g:vista_sidebar_width = 40

" Plugin: vim_current_word
" The word under cursor:
let g:vim_current_word#highlight_current_word = 1
" Enable/disable highlighting only in focused window:
let g:vim_current_word#highlight_only_in_focused_window = 1
" Enable/disable plugin:
let g:vim_current_word#enabled = 1

" Plugin: auto-pairs
" Avoid conflict with edit motion"
let g:AutoPairsShortcutBackInsert = '<M-B>'

" Plugin: vim-better-whitespace
" To strip white lines at the end of the file when stripping whitespace
let g:strip_whitelines_at_eof=1
" To highlight space characters that appear before or in-between tabs
let g:show_spaces_that_precede_tabs=1

" Plugin: vim-lsp-cxx-highlight
" c++ syntax highlighting
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1

" Plugin: fzf - fuzzy finder
" e.g. let g:fzf_command_prefix = 'Fzf' and you have FzfFiles, etc.
let g:fzf_command_prefix = 'Fzf'

" Plugin: coc-explorer
let g:coc_explorer_global_presets = {
\   '.nvim': {
\     'root-uri': '~/.config/nvim',
\     'position': 'floating',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'tab-view': {
\     'position': 'tab',
\     'quit-on-open': v:true,
\   },
\   'floating': {
\     'position': 'floating',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingTop': {
\     'position': 'floating',
\     'floating-position': 'center-top',
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingLeftside': {
\     'position': 'floating',
\     'floating-position': 'left-center',
\     'floating-width': 40,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingRightside': {
\     'position': 'floating',
\     'floating-position': 'right-center',
\     'floating-width': 40,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'leftsideBar': {
\     'width': 30,
\     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
\   }
\ }
