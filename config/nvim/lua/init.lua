-- init.lua

-- Plugin: nvim-tree
-- https://github.com/kyazdani42/nvim-tree.lua
require('nvim-tree').setup {
	auto_close = true,
	update_to_buf_dir = {
		enable = true,
		auto_open = true,
	},
	update_cwd = true,
	update_focused_file = {
		enable      = true,
		update_cwd  = true,
		ignore_list = {}
	},
	auto_close = true,
	filters = {
		dotfiles = true,
		custom = {}
	},
}
vim.g.nvim_tree_special_files = {
      Makefile = true,
	  ["Android.mk"] = true,
	  ["Kconfig"] = true,
      ["README.md"] = true,
      ["readme.md"] = true,
}
vim.g.nvim_tree_quit_on_open = 1
vim.g.nvim_tree_icon_padding = ' '

-- default will show icon by default if no icon is provided
-- default shows no icon by default
vim.g.nvim_tree_icons = {
	default = "",
	symlink = "",
	git = {
		unstaged = "✗",
		staged = "✓",
		unmerged = "",
		renamed = "➜",
		untracked = "★",
		deleted = "",
		ignored = "◌"
	},
	folder = {
		arrow_open = "",
		arrow_closed = "",
		default = "",
		open = "",
		empty = "",
		empty_open = "",
		symlink = "",
		symlink_open = "",
	},
	lsp = {
		hint = "",
		info = "",
		warning = "",
		error = "",
	}
 }

-- Plugin: treesitter
local treesitter = require('nvim-treesitter.configs')
treesitter.setup {
  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {"bash", "perl", "python", "lua", "vim", "r",
                      "c", "cpp", "c_sharp", "rust", "go", "java", "kotlin",
                      "html", "css", "typescript", "javascript",
                      "json", "markdown", "yaml", "toml",
                      "make", "cmake", "ninja",
                      "comment", "rst"},
  ignore_install = { "javascript" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = {},  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

-- Plugin: which-key
-- https://github.com/folke/which-key.nvim
-- Run ':checkhealth which_key' to see if there's any conflicting
-- keymaps that will prevent triggering WhichKey
require("which-key").setup {}

-- Plugin: nvim-cmp
-- https://github.com/hrsh7th/nvim-cmp/
require('nvim-cmp')

-- Plugin: nvim-lspconfig
-- https://github.com/neovim/nvim-lspconfig
require('nvim-lspconfig')

-- Plugin: lualine
-- https://github.com/nvim-lualine/lualine.nvim
require('nvim-lualine')

-- Plugin: bufferline
-- https://github.com/akinsho/bufferline.nvim
require('nvim-bufferline')

-- Plugin: aerial
-- https://github.com/stevearc/aerial.nvim
require('nvim-aerial')
