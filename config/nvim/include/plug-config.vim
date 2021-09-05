" Plugin: lightline-bufferline
let g:lightline#bufferline#show_number  = 1
let g:lightline#bufferline#shorten_path = 0
let g:lightline#bufferline#unnamed      = '[No Name]'

let g:lightline                  = {}
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}

" Plugin: editorconfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
au FileType gitcommit let b:EditorConfig_disable = 1

" Plugin: vim-ccls
let g:ccls_levels = 1
let g:ccls_size = 50
let g:ccls_position = 'botright'
let g:ccls_orientation = 'horizontal'

" Plugin: auto-pairs
" Avoid conflict with edit motion"
let g:AutoPairsShortcutBackInsert = '<M-B>'

" Plugin: alternate-toggler
let g:at_custom_alternates = {
\   'true': 'false',
\   'True': 'False',
\   'TRUE': 'FALSE',
\   'y': 'n',
\   'yes': 'no',
\   'Yes': 'No',
\   'YES': 'NO',
\   'and': 'or',
\   'AND': 'OR',
\   '&&': '||',
\   '1': '0'
\}

" Plugin: nvim-toggle-terminal
au TermEnter * let $GIT_EDITOR='nvr'

" Plugin: vim-commentary
au FileType c,cpp,cc,h setlocal commentstring=//\ %s

" Plugin: quick-scope
" Create black list for QS
let g:qs_buftype_blacklist = ['terminal', 'nofile']

" Plugin: vim-better-whitespace
" To strip white lines at the end of the file when stripping whitespace
let g:strip_whitelines_at_eof=1
" To highlight space characters that appear before or in-between tabs
" let g:show_spaces_that_precede_tabs=1

" Plugin: fzf - fuzzy finder
" NOTE:
" To reduce fzf error due to preview cmd, we have two choices
" 1. update kernel version (could fix this issue)
" 2. disable preview feature (workaround)
" We choose 2nd choice here. https://github.com/junegunn/fzf/issues/1486
"
" Empty value to disable preview window altogether
let g:fzf_preview_window = []
" e.g. let g:fzf_command_prefix = 'Fzf' and you have FzfFiles, etc.
let g:fzf_command_prefix = 'Fzf'
