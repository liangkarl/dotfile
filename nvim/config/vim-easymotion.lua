-- Plugin: vim-easymotion
-- https://github.com/easymotion/vim-easymotion

-- recommoand mininal setup
vim.g.EasyMotion_do_mapping = 0   -- Disable. default mappings
vim.g.EasyMotion_smartcase = 1    -- Turn on case-insensitive feature

--[[
    meaning of symbols
    f2 => hit two chars
    f => hit one char
    l => line limited
    s => search string
    n => next search string
    bd => bidirection
    sol => start of line
    eol => end of line
--]]
vim.keymap.set('n', 'f', '<Plug>(easymotion-f)')
vim.keymap.set('n', 'F', '<Plug>(easymotion-F)')
vim.keymap.set('n', 't', '<Plug>(easymotion-t)')
vim.keymap.set('n', 'T', '<Plug>(easymotion-T)')
vim.keymap.set('n', 'w<CR>', '<Plug>(easymotion-w)')
vim.keymap.set('n', 'W<CR>', '<Plug>(easymotion-W)')
vim.keymap.set('n', 'e<CR>', '<Plug>(easymotion-e)')
vim.keymap.set('n', 'E<CR>', '<Plug>(easymotion-E)')
vim.keymap.set('n', 'b<CR>', '<Plug>(easymotion-b)')
vim.keymap.set('n', 'B<CR>', '<Plug>(easymotion-B)')
vim.keymap.set('n', 'f<CR>', '<Plug>(easymotion-overwin-f2)')
vim.keymap.set('n', 't<CR>', '<Plug>(easymotion-overwin-t2)')
