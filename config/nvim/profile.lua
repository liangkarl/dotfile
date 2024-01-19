-- https://alpha2phi.medium.com/neovim-for-beginners-lua-autocmd-and-keymap-functions-3bdfe0bebe42
--
-- Set other options
-- local colorscheme = require("helpers.colorscheme")
local cmd = vim.cmd
local fn = vim.fn
local highlight = vim.api.nvim_set_hl
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local gid

-- cmd.colorscheme('material-darker')

-- Misc settings:
--
-- |matchit| plugin is enabled. Disable it with:
-- let loaded_matchit = 1
vim.g.loaded_matchit = 1

-- |g:vimsyn_embed| defaults to "l" to enable Lua highlighting

function load_position()
  -- if last visited position is available
  if fn.line("'\"") > 1 and fn.line("'\"") <= fn.line("$") then
    -- jump to the last position
    cmd("normal! g'\"")
  end
end

function edit(enable)
  if enable then
    cmd("set list showbreak=↪\\  colorcolumn=80")
    MiniTrailspace.highlight()
    vim.diagnostic.config({ virtual_text = false, virtual_lines = false, signs = false})
  else
    cmd("set nolist showbreak= colorcolumn=")
    MiniTrailspace.unhighlight()
    vim.diagnostic.config({ virtual_text = true, virtual_lines = true, signs = true})
  end
end

vim.g.loaded_matchit = 1

highlight(0, "nCursor", { fg=nil, bg='SlateBlue', cterm=nil, ctermbg=1 })
highlight(0, "iCursor", { fg=nil, bg='#ffffff', cterm=nil, ctermbg=15 })
highlight(0, "rCursor", { fg=nil, bg='Red', cterm=nil, ctermbg=12 })

-- Set cursor pattern (no blink)
vim.o.guicursor = "n-v-c-sm:block-nCursor,i-ci-ve:ver25-iCursor,r-cr-o:hor20-rCursor"

gid = augroup("Habbits", { clear = true })

-- Keep cursor line centered only in Normal mode
autocmd("CursorMoved", {
  pattern = '*',
  command = 'set scrolloff=999',
  desc = 'Set cursor line in the center',
  group = gid
})
autocmd("InsertEnter", {
  pattern = '*',
  command = 'set scrolloff=5',
  desc = 'Unset cursor line from center',
  group = gid
})

-- Reload layout
autocmd("InsertLeave", {
  pattern = '*',
  callback = function() edit(false) end,
  desc = 'Viewer Mode',
  group = gid
})
autocmd("InsertEnter", {
  pattern = '*',
  callback = function() edit(true) end,
  desc = 'Edit Mode',
  group = gid
})

-- A simple function to restore previous cursor position
autocmd("BufReadPost", {
  pattern = '*',
  callback = load_position,
  desc = 'Restore Previous Cursor Position',
  group = gid
})
-- Set no line number in terminal buffer
autocmd("TermOpen", {
  pattern = '*',
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
  end,
  desc = 'Edit Mode',
  group = gid
})

gid = augroup("PluginConfig", { clear = true })
-- FIXME: WA for autocmd not working
autocmd({ "FileReadPost", "BufReadPost" }, {
  pattern = '*',
  command = 'GuessIndent',
  desc = 'Auto Alignment',
  group = gid
})

gid = augroup("ExtraFeature", { clear = true })
-- Highlight on yank
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = gid,
})

-- windows to close with "q"
autocmd( "FileType", {
  pattern = { "help", "startuptime", "qf", "lspinfo" },
  command = [[nnoremap <buffer><silent> q :close<CR>]],
  group = gid,
})

autocmd( "FileType", {
  pattern = "man",
  command = [[nnoremap <buffer><silent> q :quit<CR>]],
  group = gid
})

-- show cursor line only in active window
autocmd( { "InsertLeave", "WinEnter" }, {
  pattern = "*",
  command = "set cursorline",
  group = gid
})

autocmd( { "InsertEnter", "WinLeave" }, {
  pattern = "*",
  command = "set nocursorline",
  group = gid
})

-- Fix shifting issue that would reset the cursor position
autocmd( { "ModeChanged" }, {
  pattern = "*:[vV\x16]*",
  callback = function () vim.b.minianimate_disable = true end,
  group = gid
})

autocmd( { "ModeChanged" }, {
  pattern = "[vV\x16]*:*",
  callback = function () vim.b.minianimate_disable = false end,
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