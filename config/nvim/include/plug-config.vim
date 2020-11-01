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

" Plugin: vim_current_word
" The word under cursor:
let g:vim_current_word#highlight_current_word = 1
" Enable/disable highlighting only in focused window:
let g:vim_current_word#highlight_only_in_focused_window = 1
" Enable/disable plugin:
let g:vim_current_word#enabled = 1

" Plugin: vim-better-whitespace
" To strip white lines at the end of the file when stripping whitespace
let g:strip_whitelines_at_eof=1
" To highlight space characters that appear before or in-between tabs
let g:show_spaces_that_precede_tabs=1

" Plugin: fzf - fuzzy finder
" e.g. let g:fzf_command_prefix = 'Fzf' and you have FzfFiles, etc.
let g:fzf_command_prefix = 'Fzf'

" Plugin: coc-explorer
let g:coc_explorer_global_presets = {
\   '.vim': {
\     'root-uri': '~/.vim',
\   },
\   'tab': {
\     'position': 'tab',
\     'quit-on-open': v:true,
\   },
\   'floating': {
\     'position': 'floating',
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
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingRightside': {
\     'position': 'floating',
\     'floating-position': 'right-center',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'simplify': {
\     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
\   }
\ }
