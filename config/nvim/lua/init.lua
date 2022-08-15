-- init.lua

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
require('config.nvim-cmp')

-- Plugin: lspkind
-- https://github.com/onsails/lspkind.nvim
require('config.lspkind')

-- Plugin: nvim-lspconfig
-- https://github.com/neovim/nvim-lspconfig
require('config.nvim-lspconfig')

-- Plugin: lualine
-- https://github.com/nvim-lualine/lualine.nvim
require('config.lualine')

-- Plugin: bufferline
-- https://github.com/akinsho/bufferline.nvim
require('config.bufferline')

-- Plugin: aerial
-- https://github.com/stevearc/aerial.nvim
require('config.aerial')

-- Plugin: nvim-tree
-- https://github.com/kyazdani42/nvim-tree.lua
require('config.nvim-tree')

-- Plugin: nvim-dap
-- https://github.com/mfussenegger/nvim-dap
require('config.nvim-dap')

-- Plugin: mason
-- https://github.com/williamboman/mason.nvim
require('config.mason')
