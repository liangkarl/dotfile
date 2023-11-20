require('outline').setup({
  symbols = {
    filter = {
      "Class",
      "Constructor",
      "Enum",
      "Function",
      "Interface",
      "Module",
      "Method",
      "Struct",
    },
  }
})

vim.keymap.set('n', '<leader>sm', ':Outline<cr>')
vim.keymap.set('n', '<leader>si', ':OutlineStatus<cr>')
