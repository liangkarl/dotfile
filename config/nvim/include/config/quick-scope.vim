" Plugin: quick-scope

" Create black list for QS
let g:qs_buftype_blacklist = ['terminal', 'nofile']

nmap <leader>q <plug>(QuickScopeToggle)
xmap <leader>q <plug>(QuickScopeToggle)

