--
-- IMPORTANT NOTICE
--
-- PLACE CONFIGURATION HERE IF THEY ARE USED FOR GLOBAL AND MAY
-- CAUSE DEPENDENCY PROBLEMS
--

local nvim_dir = vim.fn.expand('<sfile>:h')
package.path = nvim_dir .. '/?.lua;' .. package.path

-- set <leader> key ASAP to prevent dependency issue
vim.g.mapleader = ' '

vim.cmd("source " .. nvim_dir .. "/config.vim")

require('core.options')
require('core.lazy')
require('profile')
