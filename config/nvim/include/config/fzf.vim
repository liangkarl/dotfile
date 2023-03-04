" Plugin: fzf

" Plugin: fzf - fuzzy finder
" NOTE:
" To reduce fzf error due to preview cmd, we have two choices
" 1. update kernel version (could fix this issue)
" 2. disable preview feature (workaround)
" We choose 2nd choice here. https://github.com/junegunn/fzf/issues/1486
"
" Empty value to disable preview window altogether
let g:fzf_preview_window = []
" e.g. let g:fzf_command_prefix = 'Fzf' and you have FzfFiles, etc.
let g:fzf_command_prefix = 'Fzf'

if g:fuzzy_finder == 'fzf'
  nnoremap <Leader>fb :FzfBuffers<CR>
  " Recently open file
  nnoremap <Leader>fr :FzfHistory<CR>
  " Search history
  nnoremap <Leader>fs :FzfHistory/<CR>
  nnoremap <Leader>fc :FzfCommands<CR>
  nnoremap <Leader>f? :FzfMaps<CR>
  nnoremap <Leader>fm :FzfMarks<CR>
  nnoremap <Leader>fi :FzfFiletypes<CR>
endif
