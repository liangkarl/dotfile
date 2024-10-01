local opt = vim.o -- different from vim.opt

opt.wrap = true
opt.wrapmargin = 8 -- wrap lines when coming within n characters from side

opt.termguicolors = true
-- set wait time for combined keys
opt.timeoutlen = 300
-- Fix backspace indent
opt.backspace = "indent,eol,start"
-- SHAre DAta
-- Better modes.  Remeber where we are, support yankring
opt.shada = "!,'100,\"100,:20,<50,s10,h,n~/.vim.shada"

-- Set the title text in the window
opt.title = true
opt.titlestring = "%F"

-- Tab completion in command bar
opt.wildmode = "full"
opt.wildignore = "*.o,*.obj,.git,*.rbc,.pyc,__pycache__"

-- Symbols for non-charactors:
-- tab:→\ , space:·, nbsp:␣, trail:•, eol:¶, precedes:«, extends:»
opt.listchars = "tab:→ ,nbsp:␣,precedes:«,extends:»"

-- Use modeline overrides
opt.modeline = true
opt.modelines = 10

-- Set Byte Order Mask(BOM) dealing with UTF8 in window
opt.bomb = true
-- treat all files as binary to prevent from unexpected changes
opt.binary = true

-- show the line numbers with hybrid mode in the left side
opt.number = true
opt.relativenumber = true

-- Close a split window in Vim without resizing other windows
opt.equalalways = false

-- Set up font for special characters
opt.guifont = "SauceCodePro Nerd Font Mono"

opt.diffopt = opt.diffopt .. ",algorithm:histogram"

opt.backup = false
-- When vim failed to write buffer, don't create backup-like file for it.
opt.writebackup = false
opt.swapfile = false

-- Don't show mode text(eg, INSERT) as lualine has already do it
opt.showmode = false

-- Show unprintable characters hexadecimal as <xx> instead of using ^C and ~C.
opt.display = opt.display .. ",uhex"

-- disable support mouse action in normal mode.
opt.mouse = ""

opt.cursorline = true
