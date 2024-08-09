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

  -- Start-up screen
  require('config.vim-startify'),

  require('config.trouble'),

  {
    'kevinhwang91/nvim-bqf',
    config = true
  },

  -- Status line (button)
  require('config.lualine'),

  require('config.bufferline'),
  require('config.vuffers'),

  require('config.symbol-list'),

  -- Enhanced functions
  require('config.nvim-treesitter'),

  { -- share clipboard between tmux and vim
    'roxma/vim-tmux-clipboard',
  },
  { -- delete buffers
    'kazhala/close-buffers.nvim',
    config = true
  },

  require('config.stickybuf'),
  require('config.nvim-scrollbar'),
  require('config.guess-indent'),
  require('config.nvim-lastplace'),
  require('config.mini'),
  -- FIXME: replace with new matchup plugin
  -- require('config.vim-matchup'),
  {
    'nvimdev/hlsearch.nvim',
    config = true
  },
  require('config.hop'),
  require('config.alternate-toggler'),

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

  require('config.tabnine-nvim'),
  require('config.lsp-status'),
  require('config.fold-preview'),
  require('config.editorconfig'),
  require('config.ChatGPT'),
  require("config.keybind")
})
