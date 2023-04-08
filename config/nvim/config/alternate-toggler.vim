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

" Toggle boolean
nnoremap <silent> <leader>vv :ToggleAlternate<CR>


