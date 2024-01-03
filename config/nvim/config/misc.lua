-- https://alpha2phi.medium.com/neovim-for-beginners-lua-autocmd-and-keymap-functions-3bdfe0bebe42
--
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local api = vim.api

-- Highlight on yank
local yankGrp = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  command = "silent! lua vim.highlight.on_yank()",
  group = yankGrp,
})

-- windows to close with "q"
autocmd( "FileType",
  { pattern = { "help", "startuptime", "qf", "lspinfo" },
    command = [[nnoremap <buffer><silent> q :close<CR>]] })

autocmd( "FileType",
  { pattern = "man",
    command = [[nnoremap <buffer><silent> q :quit<CR>]] })

-- show cursor line only in active window
local cursorGrp = augroup( "CursorLine", { clear = true })
autocmd( { "InsertLeave", "WinEnter" },
  { pattern = "*", command = "set cursorline", group = cursorGrp })

autocmd( { "InsertEnter", "WinLeave" },
  { pattern = "*", command = "set nocursorline", group = cursorGrp })

-- Fix shifting issue that would reset the cursor position
autocmd( { "ModeChanged" },
  { pattern = "*:[vV\x16]*",
    callback = function () vim.b.minianimate_disable = true end })

autocmd( { "ModeChanged" },
  { pattern = "[vV\x16]*:*",
    callback = function () vim.b.minianimate_disable = false end })
