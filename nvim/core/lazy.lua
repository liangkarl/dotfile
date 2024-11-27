-----------------------------------------------------------
-- Plugin manager configuration file
-----------------------------------------------------------

-- Plugin manager: lazy.nvim
-- URL: https://github.com/folke/lazy.nvim
-- https://lazy.folke.io/

--[[
For information about installed plugins see the README:
neovim-lua/README.md: Plugins
https://github.com/brainfucksec/neovim-lua?tab=readme-ov-file#plugins
--]]

local m = require('core.utils')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Use a protected call so we don't error out on first use
local status_ok, lazy = pcall(require, 'lazy')require('lazy')
if not status_ok then
  return
end

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
  require('config.vim-polyglot'),

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

  -- Autocompletion
  require('config.nvim-cmp'),

  require('config.tabnine-nvim'),
  require('config.lsp-status'),
  require('config.fold-preview'),
  require('config.editorconfig'),
  require('config.ChatGPT'),

  -- LSP
  require('core.lspconfig'),

  -- Keymaps
  require("core.which-key")
})
