-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

vim.keymap.set('n', '<Leader>gs', ":lua require'dap'.toggle_breakpoint()<CR>")
vim.keymap.set('n', '<Leader>gc', ":lua require'dap'.continue()<CR>")
vim.keymap.set('n', '<Leader>g.', ":lua require'dap'.step_over()<CR>")
vim.keymap.set('n', '<Leader>g,', ":lua require'dap'.step_into()<CR>")
vim.keymap.set('n', '<Leader>gt', ":lua require'dap'.repl.open()<CR>")
