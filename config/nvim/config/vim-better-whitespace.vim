" Plugin: vim-better-whitespace

" To strip white lines at the end of the file when stripping whitespace
let g:strip_whitelines_at_eof=1
" To highlight space characters that appear before or in-between tabs
" let g:show_spaces_that_precede_tabs=1

" Remove trailing whitespace
nnoremap <silent><leader>ss :StripWhitespace<cr>
