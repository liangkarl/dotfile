-- https://alpha2phi.medium.com/neovim-for-beginners-lua-autocmd-and-keymap-functions-3bdfe0bebe42
--
local api = vim.api

-- Highlight on yank
local yankGrp = api.nvim_create_augroup("YankHighlight", { clear = true })
api.nvim_create_autocmd("TextYankPost", {
  command = "silent! lua vim.highlight.on_yank()",
  group = yankGrp,
})

-- windows to close with "q"
api.nvim_create_autocmd(
  "FileType",
  { pattern = { "help", "startuptime", "qf", "lspinfo" },
    command = [[nnoremap <buffer><silent> q :close<CR>]] }
)
api.nvim_create_autocmd(
  "FileType",
  { pattern = "man",
    command = [[nnoremap <buffer><silent> q :quit<CR>]] })
