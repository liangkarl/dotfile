" Plugin: vim-table-mode
" |----------+----------------|
" | ORIG CMD |     explain    |
" |----------+:--------------:|
" | del col  |   <leader>tdc  |
" | ins col  |   <leader>tic  |
" | tableize | Tableize/[sep] |
" |----------+----------------|
nnoremap <silent><leader>tg :TableModeToggle<cr>
" Realigned text-table
nnoremap <silent><leader>tr :TableModeRealign<cr>
" Tableize
noremap <leader>tz :Tableize/,

