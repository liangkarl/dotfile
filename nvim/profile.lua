-- https://alpha2phi.medium.com/neovim-for-beginners-lua-autocmd-and-keymap-functions-3bdfe0bebe42
--
-- Set other options
-- local colorscheme = require("helpers.colorscheme")
local m = require('helpers.utils')

local cmd = vim.cmd
local fn = vim.fn
local gid

local function load_position()
  -- if last visited position is available
  if fn.line("'\"") > 1 and fn.line("'\"") <= fn.line("$") then
    -- jump to the last position
    cmd("normal! g'\"")
  end
end

local function edit(enable)
  local space = require("mini.trailspace")

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
    vim.diagnostic.config({ virtual_text = true, virtual_lines = true, signs = true})
    space.unhighlight()
  end
end

-- cmd.colorscheme('material-darker')

m.highlight("nCursor", { fg=nil, bg='SlateBlue', cterm=nil, ctermbg=1 })
m.highlight("iCursor", { fg=nil, bg='#ffffff', cterm=nil, ctermbg=15 })
m.highlight("rCursor", { fg=nil, bg='Red', cterm=nil, ctermbg=12 })

-- Set cursor pattern (no blink)
vim.opt.guicursor = {
  "n-v-c-sm:block-nCursor",
  "i-ci-ve:ver25-iCursor",
  "r-cr-o:hor20-rCursor"
}
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 10

gid = m.augroup("Habbits")

-- Reload layout
m.autocmd("InsertLeave", '*', function() edit(false) end, {
  desc = 'Viewer Mode',
  group = gid
})
m.autocmd("InsertEnter", '*', function() edit(true) end, {
  desc = 'Edit Mode',
  group = gid
})

-- A simple function to restore previous cursor position
m.autocmd("BufReadPost", '*', load_position, {
  desc = 'Restore Previous Cursor Position',
  group = gid
})
-- Set no line number in terminal buffer
m.autocmd("TermOpen", '*', function()
    vim.wo.number = false
    vim.wo.relativenumber = false
  end, {
  desc = 'Edit Mode',
  group = gid
})

gid = m.augroup("PluginConfig")
-- FIXME: WA for autocmd not working
m.autocmd({ "FileReadPost", "BufReadPost" }, '*', function()
    if vim.o.modifiable == true then
      vim.cmd('silent !GuessIndent')
    end
  end, {
  desc = 'Auto Alignment',
  group = gid
})

gid = m.augroup("ExtraFeature")
-- Highlight on yank
m.autocmd("TextYankPost", '*', function() vim.highlight.on_yank() end, {
  group = gid,
})

-- windows to close with "q"
m.autocmd( "FileType", { "help", "startuptime", "qf", "lspinfo", "man" },
  [[nnoremap <buffer><silent> q :close<CR>]], {
  group = gid,
})

-- show cursor line only in active window
m.autocmd( { "InsertLeave", "WinEnter" }, "*", "set cursorline", { group = gid })
m.autocmd( { "InsertEnter", "WinLeave" }, "*", "set nocursorline", { group = gid })

-- FIXME: WA for mini.cursor as the color could not be changed in init.lua
m.autocmd( "BufAdd", "*", function()
    m.highlight("MiniCursorword", { fg = 'tomato', ctermfg = 'Red' })
    m.highlight("MiniCursorwordCurrent", { fg = 'tomato', ctermfg = 'Red' })
  end, {
  group = gid
})

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
