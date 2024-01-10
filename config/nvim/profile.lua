-- Set other options
local colorscheme = require("helpers.colorscheme")
vim.cmd.colorscheme(colorscheme)

-- Misc settings:
--
-- |matchit| plugin is enabled. Disable it with:
-- let loaded_matchit = 1
vim.g.loaded_matchit = 1

-- |g:vimsyn_embed| defaults to "l" to enable Lua highlighting

function RestoreCursorPosition()
  -- if last visited position is available
  if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
    -- jump to the last position
    vim.cmd("normal! g'\"")
  end
end

function ToggleEditMode(enable)
  if enable then
    vim.cmd("set list showbreak=↪\\  colorcolumn=80")
    vim.cmd("EnableWhitespace")
  else
    vim.cmd("set nolist showbreak= colorcolumn=")
    vim.cmd("DisableWhitespace")
  end
end
