local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local m = require('helpers.utils')

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

require("lazy").setup({
  -- Integration Development Environment
  { -- Start-up screen
    'mhinz/vim-startify',
    config = function()
      require('config.vim-startify')
    end
  },

  require('config.trouble'),

  {
    'kevinhwang91/nvim-bqf',
    config = true
  },

  -- Status line (button)
  require('config.lualine'),

  { -- Buffer line (top)
    'akinsho/bufferline.nvim',
    tag = 'v3.7.0',
    config = function()
      require('config.bufferline')
    end
  },
  require('config.symbol-list'),

  -- Enhanced functions
  require('config.nvim-treesitter'),

  {
    'dnlhc/glance.nvim',
    config = true
  },
  { -- share clipboard between tmux and vim
    'roxma/vim-tmux-clipboard',
  },
  { -- delete buffers
    'kazhala/close-buffers.nvim',
    config = true
  },

  require('config.stickybuf'),

  {
    'petertriho/nvim-scrollbar',
    config = function()
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
  require('config.guess-indent'),
  require('config.mini'),
  -- FIXME: replace with new matchup plugin
  -- require('config.vim-matchup'),
  {
    'nvimdev/hlsearch.nvim',
    config = true
  },
  require('config.hop'),
  { -- switch boolean value easily,
    'rmagatti/alternate-toggler',
    config = function()
      require('config.alternate-toggler')
    end
  },

  -- Formatter
  { -- format code with clang-format
    'rhysd/vim-clang-format',
    config = function()
      -- require('config.vim-clang-format')
    end
  },

  -- LSP plugin
  { -- provide unique ccls function
    'ranjithshegde/ccls.nvim',
  },

  -- Debug Tools
  require('config.nvim-dap'),

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
  require('config.neogit'),
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
  require('config.telescope'),

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

  require('config.nvim-lspconfig'),

  -- Autocompletion
  require('config.nvim-cmp'),

  {
    'codota/tabnine-nvim',
    build = "./dl_binaries.sh",
    config = function()
      require('config.tabnine-nvim')
    end,
    enabled = false,
  },
  require('config.lsp-status'),
  require('config.fold-preview'),
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
  require("config.keybind")
})
