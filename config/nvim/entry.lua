local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local nvim_dir = vim.fn.expand('<sfile>:h')
package.path = nvim_dir .. '/?.lua;' .. package.path

require("lazy").setup({
  -- Integration Development Environment
  { -- Start-up screen
    'mhinz/vim-startify',
    config = function()
      require('config.vim-startify')
    end
  },
  { -- Status line (button)
    'nvim-lualine/lualine.nvim',
    config = function()
      require('config.lualine')
    end
  },
  { -- Buffer line (top)
    'akinsho/bufferline.nvim',
    tag = 'v3.7.0',
    config = function()
      require('config.bufferline')
    end
  },
  { -- Symbol Manager
    'hedyhli/outline.nvim',
    config = function()
      require('config.outline')
    end
  },
  { -- File Explorer
    'kyazdani42/nvim-tree.lua',
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require('config.nvim-tree')
    end,
  },


  -- Enhanced functions
  { -- Syntax highlight/lint with `treesitter`
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function()
      require('config.nvim-treesitter')
    end,
  },
  { -- share clipboard between tmux and vim
    'roxma/vim-tmux-clipboard',
  },
  { -- delete buffers
    'Asheq/close-buffers.vim',
  },
  {
    'petertriho/nvim-scrollbar',
    config = function ()
      local mod = require("scrollbar")
      mod.setup({
        handlers = {
          cursor = false,
        },
        handle = {
          blend = 0,
        }
      })
    end,
  },
  {
    'nmac427/guess-indent.nvim',
    config = true,
  },
  { -- A 'Swiss Army Knife' with many small features
    'echasnovski/mini.nvim',
    config = function ()
      require('config.mini')
    end
  },
  { -- comment codes easily
    'tpope/vim-commentary',
    config = function()
      require('config.vim-commentary')
    end
  },
  { -- enhance '%' function, like if-endif
    'andymass/vim-matchup',
    config = function()
      require('config.vim-matchup')
    end
  },
  { -- preview the replace/search result
    'markonm/traces.vim',
  },
  { -- make string search more convenient.
    'haya14busa/is.vim',
  },
  { -- move cursor location like vimium
    'easymotion/vim-easymotion',
    config = function()
      require('config.vim-easymotion')
    end
  },
  { -- switch boolean value easily,
    'rmagatti/alternate-toggler',
    config = function()
      require('config.alternate-toggler')
    end
  },
  { -- edit Markdown table easily
    'dhruvasagar/vim-table-mode',
  },
  { -- text object selection with +/-
    'terryma/vim-expand-region',
  },
  { -- show/remove trailing space
    'ntpeters/vim-better-whitespace',
    config = function()
      require('config.vim-better-whitespace')
    end
  },

  -- Formatter
  { -- format code with clang-format
    'rhysd/vim-clang-format',
    config = function()
      -- require('config.vim-clang-format')
    end
  },

  -- Autocompletion (without LSP source)
  { -- AI assist for completion
    'tzachar/cmp-tabnine',
    build = './install.sh',
    dependencies = {
      'hrsh7th/nvim-cmp'
    },
    config = function()
      -- require('config.cmp-tabnine')
    end,
  },
  { -- adjust scroll menu width
    'onsails/lspkind.nvim',
    config = function()
      require('config.lspkind')
    end

  },
  { -- snippet engine of buffer words
    'hrsh7th/cmp-buffer',
    config = function()
      -- require('config.cmp-buffer')
    end
  },

  -- LSP plugin
  { -- provide unique ccls function
    'ranjithshegde/ccls.nvim',
  },

  -- Debug Tools
  { -- Debug Adapter Protocol client implementation
    'mfussenegger/nvim-dap',
    config = function()
      require('config.nvim-dap')
    end
  },

  -- Git
  { --   " git blame whole file
    'liangkarl/tig-explorer.vim',
    config = function()
      require('config.tig-explorer')
    end
  },
  { -- show diff symbols aside via git diff
    'lewis6991/gitsigns.nvim',
    config = true,
    event = "VeryLazy",
  },
  { -- git status
    'TimUntersberger/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('config.neogit')
    end
  },
  { -- git diff
    'sindrets/diffview.nvim',
    config = function()
      -- require('config.diffview')
    end
  },

  -- Theme
  {
    'marko-cerovac/material.nvim',
    init = function()
      require('material').setup({
        plugins = {
           "dap",
           "gitsigns",
           "neogit",
           "nvim-cmp",
           "nvim-tree",
           "nvim-web-devicons",
           "which-key",
           "trouble",
           "mini",
           -- "telescope",
        },
      })
      vim.g.material_style = 'darker'
      vim.cmd('colorscheme material-darker')
    end,
  },
  {
    'sainnhe/sonokai',
    config = function()
      vim.g.sonokai_style = 'shusia'
      vim.g.sonokai_enable_italic = 1
      vim.g.sonokai_disable_italic_comment = 1
    end
  },
  {
    'sainnhe/gruvbox-material',
    config = function()
      vim.cmd('set background=dark')
      vim.g.gruvbox_material_background = 'soft'
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_disable_italic_comment = 1
      vim.g.gruvbox_material_better_performance = 1
    end
  },
  {
    'navarasu/onedark.nvim',
    config = function()
      vim.g.onedark_style = 'warmer'
    end
  },

  -- Fuzzy Finder
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('config.telescope')
    end,
  },
  { -- provides superior project management
    "ahmedkhalf/project.nvim",
    config = function()
      require('config.project')
    end,
  },

  -- Terminal
  {
    'akinsho/toggleterm.nvim',
    version = "v2.7.0",
    config = function()
      require('config.toggleterm')
    end,
    event = "VeryLazy",
  },

  -- Integration Development Environment
  { -- view startup event timing with `--startuptime`
    "dstein64/vim-startuptime",
    -- lazy-load on a command
    cmd = "StartupTime",
    -- init is called during startup. Configuration for vim plugins typically should be set in an init function
    init = function()
      vim.g.startuptime_tries = 10
    end,
  },

  -- Prerequisite
  -- NOTE:
  -- autocompletion seems better in clangd, instead of ccls
  -- Try to switch multi LSP in config
  -- xavierd/clang_complete
  { -- Autocomplete framework
    'hrsh7th/nvim-cmp',
    -- load cmp on InsertEnter
    event = "InsertEnter",
    dependencies = {
      -- Snippet engine with LSP backend
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      -- Interface between nvim-cmp and luasnip
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      -- Snippet engine of buffer words
      'hrsh7th/cmp-buffer',
    },
    config = function()
      require('config.nvim-cmp')
    end,
  },
  {
    'L3MON4D3/LuaSnip',
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    event = "InsertEnter",
    config = function ()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  { -- LSP configuration
    'neovim/nvim-lspconfig',
    config = function()
      require('config.nvim-lspconfig')
    end,
    event = "VeryLazy",
  },
  { -- Install LSP servers
    "williamboman/mason.nvim",
    build = ":MasonUpdate", -- :MasonUpdate updates registry contents
    config = function()
      require('config.mason')
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls", "bashls", "vimls",
        "clangd", "jdtls",
        "pyright",
      },
    },
  },
  {
    'codota/tabnine-nvim',
    build = "./dl_binaries.sh",
    config = function()
      require('config.tabnine-nvim')
    end,
    enabled = false,
  },
  {
    'nvim-lua/lsp-status.nvim',
    config = function()
      -- require('config.lsp-status')
    end
  },
  { -- Display cheat sheet of vim shortcut
    'folke/which-key.nvim',
    config = true,
  },
  { -- setup appearance of indent, space, etc.
    -- FIXME:
    -- 1. This plugin is included in Nvim 0.9, so the config should be rewritten
    -- 2. editorconfig could be used in creating new file, and disabled in
    --    editing existed files
    'editorconfig/editorconfig-vim',
    config = function()
      require('config.editorconfig')
    end,
    enabled = false,
  },

  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        api_key_cmd = "echo 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"
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    },
    enabled = false,
  },
})

require('config.misc')
