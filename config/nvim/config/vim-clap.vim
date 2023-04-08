" Plugin: vim-clap
if g:fuzzy_finder == 'clap'
  nnoremap <Leader>fb :Clap buffers<CR>
  " Recently open file
  nnoremap <Leader>fr :Clap history<CR>
  " Search history
  nnoremap <Leader>fs :Clap hist/<CR>
  nnoremap <Leader>fc :Clap hist:<CR>
  nnoremap <Leader>f? :Clap maps<CR>
  nnoremap <Leader>fm :Clap marks<CR>
endif



