-- Plugin: neogit
-- https://github.com/NeogitOrg/neogit

require('neogit').setup {}

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>ng', '<cmd>Neogit<cr>', opts)
