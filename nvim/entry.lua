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
  require('config.theme'),

  -- Fuzzy Finder
  require('config.telescope'),

  -- Terminal
  -- NOTE: Remove it as change to tmux console

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
  require('config.editorconfig'),

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
