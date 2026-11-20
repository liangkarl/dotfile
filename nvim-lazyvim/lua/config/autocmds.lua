local group = vim.api.nvim_create_augroup("DotfileProfile", { clear = true })

local function highlights()
  local hl = vim.api.nvim_set_hl
  hl(0, "LineNrAbove", { fg = "#424242" })
  hl(0, "LineNrBelow", { link = "LineNrAbove" })
  hl(0, "LineNr", { link = "CursorLineNr" })
  hl(0, "rCursor", { bg = "Red", ctermbg = 12 })
  hl(0, "CurSearch", { underline = true, bold = true, reverse = true, fg = "Gold" })
  hl(0, "IncSearch", { underline = true, bold = true, reverse = true, fg = "White" })
  hl(0, "Search", { undercurl = true, italic = true, fg = "Tomato" })
  hl(0, "CursorLine", { bg = "#2a2a2a", ctermbg = 236 })
  hl(0, "MiniCursorword", { italic = true, underline = true, sp = "Tomato", ctermfg = "Red" })
  hl(0, "MiniCursorwordCurrent", { underline = true, sp = "Tomato", ctermfg = "Red" })
end

vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = highlights })
highlights()

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  group = group,
  callback = function(event)
    if vim.bo[event.buf].buftype ~= "" or not vim.bo[event.buf].modifiable then
      return
    end
    local editing = event.event == "InsertEnter"
    vim.wo.list = editing
    if editing then
      vim.wo.listchars = "tab:→ ,nbsp:␣,precedes:«,extends:»"
    end
    vim.wo.colorcolumn = editing and "80" or ""
    vim.wo.scrolloff = editing and 5 or 999
    vim.wo.sidescrolloff = editing and 5 or 10
    vim.wo.cursorline = not editing
    if editing then
      require("mini.trailspace").highlight()
    else
      require("mini.trailspace").unhighlight()
    end
  end,
})

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = group,
  callback = function(event)
    if vim.bo[event.buf].buftype == "" and #vim.diagnostic.get(event.buf) > 0 then
      vim.diagnostic.open_float({ focusable = false })
    end
  end,
})

vim.api.nvim_create_autocmd("TermEnter", {
  group = group,
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
  end,
})
