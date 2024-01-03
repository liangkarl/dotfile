-- Plugin: vim-commentary
--
vim.cmd([[
  au FileType c,cpp,cc,h setlocal commentstring=//\\ %s
  " Plugin: vim-commentary
  " Toggle comment
  noremap <silent><leader>gg :Commentary<cr>
]])
