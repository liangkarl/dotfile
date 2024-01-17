local nvim_dir = vim.fn.expand('<sfile>:h')
package.path = nvim_dir .. '/?.lua;' .. package.path

vim.cmd("source " .. nvim_dir .. "/config.vim")
vim.cmd("source " .. nvim_dir .. "/keybind.vim")

require('options')
require('entry')
require('profile')
