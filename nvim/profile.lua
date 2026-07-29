-- https://alpha2phi.medium.com/neovim-for-beginners-lua-autocmd-and-keymap-functions-3bdfe0bebe42
--
-- Set other options
-- local colorscheme = require("core.colorscheme")
local m = require('core.utils')

local vim = vim
local cmd = vim.cmd
local fn = vim.fn
local gid

local function edit(enable)
  local space = require("mini.trailspace")

  if vim.b.skip_edit == true then
    return
  end

  vim.g.set_list(enable)
  if enable then
    vim.opt.colorcolumn = '80'
    vim.opt.scrolloff = 5
    vim.opt.sidescrolloff = 5
    space.highlight()
  else
    vim.opt.colorcolumn = ''
    vim.opt.scrolloff = 999
    vim.opt.sidescrolloff = 10
    space.unhighlight()
  end
end

vim.g.editorconfig = false
-- cmd.colorscheme('material-darker')

-- https://stackoverflow.com/questions/69290794/
vim.diagnostic.config({ virtual_text = false })
vim.o.updatetime = 1000
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

vim.cmd("highlight clear LineNr")
vim.cmd("highlight clear CursorLine")
vim.cmd("highlight LineNrAbove guifg=#424242")
vim.cmd("highlight link LineNrBelow LineNrAbove")
vim.cmd("highlight link LineNr CursorLineNr")

m.highlight("nCursor", { fg=nil, bg=nil, cterm=nil, ctermbg=nil })
m.highlight("rCursor", { fg=nil, bg='Red', cterm=nil, ctermbg=12 })
-- m.highlight("iCursor", { fg=nil, bg='#ffffff', cterm=nil, ctermbg=15 })
vim.cmd('hi CurSearch gui=underline,bold,reverse guifg=gold guibg=NONE')
vim.cmd('hi IncSearch gui=underline,bold,reverse guifg=white guibg=NONE')
vim.cmd('hi Search gui=undercurl,italic guifg=tomato guibg=NONE')
vim.cmd('hi CursorLine cterm=NONE ctermbg=236 gui=NONE guibg=#2a2a2a')

-- Set cursor pattern (no blink)
vim.opt.guicursor = {
  "n-v-c-sm:block-blinkon300-blinkoff300-nCursor",
  "i-ci-ve:ver25-blinkon300-blinkoff300-iCursor",
  "r-cr-o:hor20-blinkon300-blinkoff300-rCursor"
}
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 10
vim.opt.inccommand='nosplit'

gid = m.augroup("UserProfile")

-- Reload layout
m.autocmd("FileType", "Telescope*", function () vim.b.skip_edit = true end, {
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

function detect_syntax_hl()
    local ft = vim.bo.filetype

    if require("nvim-treesitter.parsers").has_parser(ft) then
        cmd("syntax off")
        cmd("TSBufEnable highlight")
    else
        cmd("TSBufDisable highlight")
        cmd("syntax on")
    end
end

m.autocmd({"VimEnter", "BufEnter"}, '*', detect_syntax_hl, {
  desc = "Enable Treesitter highlight if parser exists, otherwise fallback to syntax highlight",
  group = gid
})

-- show cursor line only in active window
m.autocmd( { "InsertLeave", "WinEnter" }, "*", "set cursorline", { group = gid })
m.autocmd( { "InsertEnter", "WinLeave" }, "*", "set nocursorline", { group = gid })

m.highlight("MiniCursorword", { italic = true, underline = true, sp = 'tomato', ctermfg = 'Red' })
m.highlight("MiniCursorwordCurrent", { underline = true, sp = 'tomato', ctermfg = 'Red' })

m.autocmd("BufReadPost", "*", 'silent! GuessIndent', { group = gid })
m.autocmd("VimEnter", "*", 'clearjumps', { group = gid })

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TermOpen" }, {
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.schedule(function()
        vim.b.miniindentscope_disable = true
        vim.cmd("startinsert")
      end)
    end
  end,
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

cmd("syntax off")

-- WARN: disable nvim deprecate API warning
vim.deprecate = function() end

vim.keymap.set("n", "<leader>P", function()
  local text = vim.fn.getreg('"')       -- 取 unnamed register
  text = text:gsub("\x00", "")
  vim.fn.setreg('p', text, 'l')
  vim.cmd.normal('"pP')
end, { desc = "Paste visual block as separate lines" })

vim.keymap.set("n", "<leader>p", function()
  local text = vim.fn.getreg('"')       -- 取 unnamed register
  text = text:gsub("\x00", "")
  vim.fn.setreg('p', text, 'l')
  vim.cmd.normal('"pp')
end, { desc = "Paste visual block as separate lines" })

-- Cancel xclip/xsel support and replace with CopyQ
-- Nvim Preparation
local copyq_add_and_copy = [[
tmp=$(mktemp) || exit 1
trap 'rm -f "$tmp"' EXIT

cat >"$tmp" || exit 1
copyq add - <"$tmp" || exit 1
copyq copy - <"$tmp"
]]
vim.opt.clipboard = ""
vim.g.clipboard = {
  name = "copyq",

  copy = {
    ["+"] = { "sh", "-c", copyq_add_and_copy },
    ["*"] = { "sh", "-c", copyq_add_and_copy },
  },

  paste = {
    ["+"] = { "copyq", "clipboard" },
    ["*"] = { "copyq", "clipboard" },
  },

  cache_enabled = 0,
}
