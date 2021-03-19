" Plugin: lightline-bufferline
let g:lightline#bufferline#show_number  = 1
let g:lightline#bufferline#shorten_path = 0
let g:lightline#bufferline#unnamed      = '[No Name]'

let g:lightline                  = {}
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}

" Plugin: Vista.vim
function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction
set statusline+=%{NearestMethodOrFunction()}

" Show the nearest function in your statusline automatically,
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

" Show those pretty symbols.
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

let g:vista_sidebar_width = 40

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
" Disable showing trailing white space in coc-explorer
autocmd User CocExplorerOpenPre DisableWhitespace

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
\   'buffer': {
\     'position': 'floating',
\     'floating-width': 80,
\     'floating-height': 20,
\     'sources': [{'name': 'buffer', 'expand': v:true}],
\   },
\   'open.nvim': {
\     'root-uri': '~/.config/nvim',
\     'position': 'floating',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\     'file-child-template':'[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1][modified][readonly growRight 1 omitCenter 5][size]',
\     'sources': [{'name': 'file', 'expand': v:true}],
\   },
\   'center': {
\     'position': 'floating',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\     'file-child-template':'[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1][modified][readonly growRight 1 omitCenter 5][size]',
\     'sources': [{'name': 'file', 'expand': v:true}],
\   },
\   'tabview': {
\     'position': 'tab',
\     'quit-on-open': v:true,
\     'file-child-template':'[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1][modified][readonly growRight 1 omitCenter 5][size]',
\     'sources': [{'name': 'file', 'expand': v:true}],
\   },
\   'top': {
\     'position': 'floating',
\     'floating-position': 'center-top',
\     'open-action-strategy': 'sourceWindow',
\     'file-child-template':'[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1][modified][readonly growRight 1 omitCenter 5][size]',
\     'sources': [{'name': 'file', 'expand': v:true}],
\   },
\   'right': {
\     'position': 'floating',
\     'floating-position': 'right-center',
\     'floating-width': 40,
\     'open-action-strategy': 'sourceWindow',
\     'file-child-template':'[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1][modified][readonly growRight 1 omitCenter 5][size]',
\     'sources': [{'name': 'file', 'expand': v:true}],
\   },
\   'left': {
\     'position': 'floating',
\     'floating-position': 'left-center',
\     'floating-width': 40,
\     'open-action-strategy': 'sourceWindow',
\     'file-child-template':'[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1][modified][readonly growRight 1 omitCenter 5][size]',
\     'sources': [{'name': 'file', 'expand': v:true}],
\   },
\   'leftFix': {
\     'width': 30,
\     'file-child-template':'[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1][modified][readonly growRight 1 omitCenter 5][size]',
\     'sources': [{'name': 'file', 'expand': v:true}],
\   },
\ }
