" Plugin: skim

" Plugin: skim - fuzzy finder
" e.g. let g:fzf_command_prefix = 'Skim' and you have SkimFiles, etc.
let g:fzf_command_prefix = 'Skim'

nnoremap <leader>fb :SkimBuffers<cr>
" Recently open file
nnoremap <leader>fr :SkimHistory<cr>
" Search history
nnoremap <leader>fs :SkimHistory/<cr>
nnoremap <leader>fc :SkimCommands<cr>
nnoremap <leader>f? :SkimMaps<cr>
nnoremap <leader>fm :SkimMarks<cr>
nnoremap <leader>fi :SkimFiletypes<cr>
