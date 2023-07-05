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
    'stevearc/aerial.nvim',
    config = function()
      require('config.aerial')
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
  { -- A 'Swiss Army Knife' with many small features
    'echasnovski/mini.nvim',
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
  { -- enhance [/{/'..., auto balance pairs
    'Krasjet/auto.pairs',
    config = function()
      require('config.auto-pairs')
    end
  },
  { -- enhance f/F and rendering colors in a line
    'unblevable/quick-scope',
    config = function()
      require('config.quick-scope')
    end
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
    enabled = false
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
      -- require('config.neogit')
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
      -- require('config.material')
      vim.cmd('colorscheme material-darker')
    end,
  },
  {
    'sainnhe/sonokai',
    config = function()
      require('config.sonokai')
    end
  },
  {
    'sainnhe/gruvbox-material',
    config = function()
      require('config.gruvbox-material')
    end
  },
  {
    'navarasu/onedark.nvim',
    config = function()
      require('config.onedark')
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
      -- LSP configuration
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      -- 'hrsh7th/cmp-buffer',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
      -- 'onsails/lspkind.nvim',
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
    end
  },
  { -- Install LSP servers
    "williamboman/mason.nvim",
    build = ":MasonUpdate", -- :MasonUpdate updates registry contents
    config = function()
      require('config.mason')
    end,
    event = "VeryLazy",
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
    event = "VeryLazy",
  },
  {
    'codota/tabnine-nvim',
    build = "./dl_binaries.sh",
    config = function()
      require('config.tabnine-nvim')
    end
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
    'editorconfig/editorconfig-vim',
    config = function()
      require('config.editorconfig')
    end

  },
})
