" Plugin: vim-table-mode
" |----------+----------------|
" | ORIG CMD |     explain    |
" |----------+:--------------:|
" | del col  |   <Leader>tdc  |
" | ins col  |   <Leader>tic  |
" | tableize | Tableize/[sep] |
" |----------+----------------|
nnoremap <silent><Leader>tg :TableModeToggle<CR>
" Realigned text-table
nnoremap <silent><Leader>tr :TableModeRealign<CR>
" Tableize
noremap <Leader>tz :Tableize/,

