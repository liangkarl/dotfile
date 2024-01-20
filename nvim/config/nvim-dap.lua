-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

vim.keymap.set('n', '<leader>gs', ":lua require'dap'.toggle_breakpoint()<cr>")
vim.keymap.set('n', '<leader>gc', ":lua require'dap'.continue()<cr>")
vim.keymap.set('n', '<leader>g.', ":lua require'dap'.step_over()<cr>")
vim.keymap.set('n', '<leader>g,', ":lua require'dap'.step_into()<cr>")
vim.keymap.set('n', '<leader>gt', ":lua require'dap'.repl.open()<cr>")
