-- https://alpha2phi.medium.com/neovim-for-beginners-lua-autocmd-and-keymap-functions-3bdfe0bebe42
--
-- Set other options
-- local colorscheme = require("helpers.colorscheme")
local m = require('helpers.utils')

local vim = vim
local cmd = vim.cmd
local fn = vim.fn
local gid

local function edit(enable)
  local space = require("mini.trailspace")

  if vim.b.skip_edit == true then
    return
  end

  if enable then
    vim.opt.list = true
    vim.opt.showbreak = '↪ '
    vim.opt.colorcolumn = '80'
    vim.opt.scrolloff = 5
    vim.opt.sidescrolloff = 5
    vim.diagnostic.config({ virtual_text = false, virtual_lines = false, signs = false})
    space.highlight()
  else
    vim.opt.list = false
    vim.opt.showbreak = ''
    vim.opt.colorcolumn = ''
    vim.opt.scrolloff = 999
    vim.opt.sidescrolloff = 10
    vim.diagnostic.config({ virtual_text = true, virtual_lines = true, signs = false})
    space.unhighlight()
  end
end

vim.g.editorconfig = false
-- cmd.colorscheme('material-darker')

m.highlight("nCursor", { fg=nil, bg='SlateBlue', cterm=nil, ctermbg=1 })
m.highlight("iCursor", { fg=nil, bg='#ffffff', cterm=nil, ctermbg=15 })
m.highlight("rCursor", { fg=nil, bg='Red', cterm=nil, ctermbg=12 })
vim.cmd('hi CurSearch guifg=gray90 guibg=PeachPuff4')
vim.cmd('hi IncSearch guifg=PeachPuff4 guibg=gray90')
vim.cmd('hi Search guifg=PeachPuff4 guibg=PeachPuff1')

-- Set cursor pattern (no blink)
vim.opt.guicursor = {
  "n-v-c-sm:block-nCursor",
  "i-ci-ve:ver25-iCursor",
  "r-cr-o:hor20-rCursor"
}
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 10
vim.opt.inccommand='nosplit'

gid = m.augroup("UserProfile")

-- Reload layout
m.autocmd("FIleType", "Telescope*", function () vim.b.skip_edit = true end, {
  desc = "Black list for edit mode",
  group = gid
})
m.autocmd("InsertLeave", '*', function() edit(false) end, {
  desc = 'Viewer Mode',
  group = gid
})
m.autocmd("InsertEnter", '*', function() edit(true) end, {
  desc = 'Edit Mode',
  group = gid
})

-- Set no line number in terminal buffer
m.autocmd("TermEnter", '*', function()
    vim.wo.number = false
    vim.wo.relativenumber = false
  end, {
  desc = 'Hide numbers while enter',
  group = gid
})

m.autocmd("TermLeave", '*', function()
    vim.wo.number = true
    vim.wo.relativenumber = true
  end, {
  desc = 'Show numbers after leave',
  group = gid
})

-- FIXME: WA for autocmd not working
m.autocmd({ "FileReadPost", "BufReadPost" }, '*', function()
    if vim.o.modifiable == true then
      vim.g.editorconfig = true
      require('editorconfig').config(0)
      vim.g.editorconfig = false
      vim.cmd('silent !GuessIndent')
    end
  end, {
  desc = 'Auto Alignment',
  group = gid
})

-- Highlight on yank
m.autocmd("TextYankPost", '*', function() vim.highlight.on_yank() end, {
  group = gid,
})

-- show cursor line only in active window
m.autocmd( { "InsertLeave", "WinEnter" }, "*", "set cursorline", { group = gid })
m.autocmd( { "InsertEnter", "WinLeave" }, "*", "set nocursorline", { group = gid })

m.highlight("MiniCursorword", { fg = 'tomato', ctermfg = 'Red' })
m.highlight("MiniCursorwordCurrent", { fg = 'tomato', ctermfg = 'Red' })

m.autocmd("BufReadPost", "*", 'GuessIndent', { group = gid })

cmd([[
  " no one is really happy until you have this shortcuts
  cab W! w!
  cab Q! q!
  cab Wa wa
  cab Wq wq
  cab wQ wq
  cab WQ wq
  cab W w
  cab Q q
]])
