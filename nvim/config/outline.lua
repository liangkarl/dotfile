require('outline').setup({
  symbols = {
    filter = {
      "Class",
      "Function",
      "Module",
      "Method",
      "Struct",
    },
  }
})

vim.keymap.set('n', '<leader>sm', ':Outline<cr>')
vim.keymap.set('n', '<leader>si', ':OutlineStatus<cr>')
