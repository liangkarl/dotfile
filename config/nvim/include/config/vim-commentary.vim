" Plugin: vim-commentary
"
au FileType c,cpp,cc,h setlocal commentstring=//\ %s

" Toggle comment
noremap <silent><Leader>gg :Commentary<CR>


