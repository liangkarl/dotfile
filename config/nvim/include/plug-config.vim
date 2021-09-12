" Plugin: lightline-bufferline
let g:lightline#bufferline#show_number  = 1
let g:lightline#bufferline#shorten_path = 0
let g:lightline#bufferline#unnamed      = '[No Name]'

let g:lightline                  = {}
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}

" Plugin: Startify
" Show startify when there is no opened buffers
autocmd BufDelete * if empty(filter(tabpagebuflist(), '!buflisted(v:val)')) && bufname() == "" | Startify | endif

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

" Plugin: vim-lsp-cxx-highlight
" c++ syntax highlighting
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1

" Plugin: fzf - fuzzy finder
" e.g. let g:fzf_command_prefix = 'Fzf' and you have FzfFiles, etc.
let g:fzf_command_prefix = 'Fzf'

