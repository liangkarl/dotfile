local opt = vim.o -- different from vim.opt
local g = vim.g

-------------------------------------------------
--- General
-------------------------------------------------
opt.termguicolors = true
opt.timeoutlen = 300         -- set wait time for combined keys
opt.wildmode = "full"        -- Tab completion in command bar
opt.wildignore = "*.o,*.obj,.git,*.rbc,.pyc,__pycache__"
-- Symbols for non-charactors:
-- tab:→\ , space:·, nbsp:␣, trail:•, eol:¶, precedes:«, extends:»
opt.listchars = "tab:→ ,nbsp:␣,precedes:«,extends:»"
opt.bomb = true              -- Set Byte Order Mask(BOM) dealing with UTF8 in window
opt.equalalways = false      -- Close a split window in Vim without resizing other windows
opt.mouse = ""               -- disable support mouse action in normal mode.
opt.diffopt = opt.diffopt .. ",algorithm:histogram"
opt.display = opt.display .. ",uhex" -- Show unprintable characters hexadecimal as <xx> instead of using ^C and ~C.
opt.scrolljump = 5

-------------------------------------------------
--- File
-------------------------------------------------
opt.backup = false
opt.writebackup = false      -- When vim failed to write buffer, don't create backup-like file for it.
opt.swapfile = false
opt.binary = true            -- treat all files as binary to prevent from unexpected changes
-- SHAre DAta
-- Better modes.  Remeber where we are, support yankring
opt.shada = "!,'100,\"100,:20,<50,s10,h,n~/.vim.shada"

-------------------------------------------------
--- Neovim UI
-------------------------------------------------
opt.wrap = true
opt.wrapmargin = 8           -- wrap lines when coming within n characters from side
opt.title = true             -- Set the title text in the window
opt.titlestring = "%F"
opt.backspace = "indent,eol,start" -- Fix backspace indent
opt.modeline = true          -- Use modeline overrides
opt.modelines = 10
opt.number = true            -- show the line numbers with hybrid mode in the left side
opt.relativenumber = true
opt.guifont = "SauceCodePro Nerd Font Mono" -- Set up font for special characters
opt.cursorline = true
opt.showmode = false         -- Don't show mode text(eg, INSERT) as lualine has already do it

-- https://superuser.com/questions/1202889/vim-syntax-highlight-limited-to-3000-chars
opt.synmaxcol = 0
opt.showmatch = true
-- vim.cmd("syntax sync fromstart")

-----------------------------------------------------------
-- Startup
-----------------------------------------------------------
-- Disable builtin plugins
local disabled_built_ins = {
   "2html_plugin",
   "getscript",
   "getscriptPlugin",
   "gzip",
   "logipat",
   "netrw",
   "netrwPlugin",
   "netrwSettings",
   "netrwFileHandlers",
   "matchit",
   "tar",
   "tarPlugin",
   "rrhelper",
   "spellfile_plugin",
   "vimball",
   "vimballPlugin",
   "zip",
   "zipPlugin",
   "tutor",
   "rplugin",
   "synmenu",
   "optwin",
   "compiler",
   "bugreport",
   "ftplugin",
}

for _, plugin in pairs(disabled_built_ins) do
   g["loaded_" .. plugin] = 1
end
