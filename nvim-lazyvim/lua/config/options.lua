vim.g.lazyvim_picker = "telescope"
vim.g.root_spec = { "lsp", { ".root", ".git" }, "cwd" }
vim.g.autoformat = false

vim.opt.timeoutlen = 600
vim.opt.mouse = ""
vim.opt.equalalways = false
vim.opt.swapfile = false
vim.opt.wrap = true
vim.opt.wrapmargin = 8
vim.opt.list = false
vim.opt.title = true
vim.opt.titlestring = "%F"
vim.opt.guifont = "SauceCodePro Nerd Font Mono"
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.wildmode = "full"
vim.opt.wildignore:append({ "*.o", "*.obj", ".git", "*.rbc", ".pyc", "__pycache__" })
vim.opt.diffopt:append("algorithm:histogram")
vim.opt.display:append("uhex")
vim.opt.scrolljump = 5
vim.opt.modelines = 10
vim.opt.synmaxcol = 0
vim.opt.showmatch = true
vim.opt.laststatus = 2
vim.opt.updatetime = 1000
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 10
vim.opt.guicursor = {
  "n-v-c-sm:block-blinkon300-blinkoff300-nCursor",
  "i-ci-ve:ver25-blinkon300-blinkoff300-iCursor",
  "r-cr-o:hor20-blinkon300-blinkoff300-rCursor",
}

-- LazyVim's config/options.lua uses unnamedplus locally and clears clipboard
-- over SSH to allow Neovim's OSC 52 integration. Use CopyQ for explicit + and *.
if vim.fn.executable("copyq") == 1 then
  local copy = {
    "sh",
    "-c",
    [[
tmp=$(mktemp) || exit 1
trap 'rm -f "$tmp"' EXIT

cat >"$tmp" || exit 1
copyq add - <"$tmp" || exit 1
copyq copy - <"$tmp"
]],
  }
  local paste = { "copyq", "clipboard" }
  vim.opt.clipboard = ""
  vim.g.clipboard = {
    name = "copyq",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
    cache_enabled = 0,
  }
end
