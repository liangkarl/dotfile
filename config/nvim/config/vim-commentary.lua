-- Plugin: vim-commentary
--
local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
  pattern = { "c", "cpp", "cc", "h" },
  callback = function () vim.bo.commentstring="// %s" end,
})

vim.cmd([[
  " Toggle comment
  noremap <silent><leader>gg :Commentary<cr>
]])
