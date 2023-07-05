-- Plugin: quick-scope
-- https://github.com/unblevable/quick-scope

-- Create black list for QS
vim.g.qs_buftype_blacklist = {
  'terminal', 'nofile',
  'help', 'quickfix', 'man',
  'startify', 'NvimTree', 'aerial',
}

-- FIXME: there are some errors if you uncomment this command
-- Trigger a highlight in the appropriate direction when pressing these keys:
-- vim.g.qs_highlight_on_keys = {'f', 'F', 't', 'T'}

-- vim.cmd('highlight QuickScopePrimary guifg=LightGray guibg=DarkGreen guifg=LightGray ctermbg=DarkGreen')
-- vim.cmd('highlight QuickScopeSecondary guifg=LightGray guibg=DarkRed guifg=LightGray ctermbg=DarkRed')

-- -- Keep color codes after changing color scheme
-- vim.cmd([[
-- augroup qs_colors
--   autocmd!
--   autocmd ColorScheme * highlight QuickScopePrimary guifg=LightGray guibg=DarkGreen guifg=LightGray ctermbg=DarkGreen
--   autocmd ColorScheme * highlight QuickScopeSecondary guifg=LightGray guibg=DarkRed guifg=LightGray ctermbg=DarkRed
-- augroup END
-- ]])
