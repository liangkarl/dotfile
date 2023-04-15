" Plugin: quick-scope

" Create black list for QS
let g:qs_buftype_blacklist = ['terminal', 'nofile']

" pink: 2f/2F <x> => jump to pink char
" blue: f/F <x> => jump to blue char
nmap <leader>jt <plug>(QuickScopeToggle)
xmap <leader>jt <plug>(QuickScopeToggle)

