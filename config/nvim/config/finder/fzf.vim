" Plugin: fzf

" Plugin: fzf - fuzzy finder
" e.g. let g:fzf_command_prefix = 'Fzf' and you have FzfFiles, etc.
let g:fzf_command_prefix = 'Fzf'

nnoremap <leader>fb :FzfBuffers<cr>
" Recently open file
nnoremap <leader>fr :FzfHistory<cr>
" Search history
nnoremap <leader>fs :FzfHistory/<cr>
nnoremap <leader>fc :FzfCommands<cr>
nnoremap <leader>f? :FzfMaps<cr>
nnoremap <leader>fm :FzfMarks<cr>
nnoremap <leader>fi :FzfFiletypes<cr>
