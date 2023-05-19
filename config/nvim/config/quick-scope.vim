" Plugin: quick-scope
" https://github.com/unblevable/quick-scope

" Create black list for QS
let g:qs_buftype_blacklist = ['terminal', 'nofile']

" Trigger a highlight in the appropriate direction when pressing these keys:
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

highlight QuickScopePrimary guifg=LightGray guibg=DarkGreen guifg=LightGray ctermbg=DarkGreen
highlight QuickScopeSecondary guifg=LightGray guibg=DarkRed guifg=LightGray ctermbg=DarkRed

" Keep color codes after changing color scheme
augroup qs_colors
  autocmd!
  autocmd ColorScheme * highlight QuickScopePrimary guifg=LightGray guibg=DarkGreen guifg=LightGray ctermbg=DarkGreen
  autocmd ColorScheme * highlight QuickScopeSecondary guifg=LightGray guibg=DarkRed guifg=LightGray ctermbg=DarkRed
augroup END
