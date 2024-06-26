return { -- Syntax highlight/lint with `treesitter`
  -- NOTE: treesitter might have to update after updating neovim
  'nvim-treesitter/nvim-treesitter',
  build = ":TSUpdateSync",
  tag = 'v0.9.1',
  config = function()
    local treesitter = require('nvim-treesitter.configs')
    local vim = vim

    treesitter.setup {
      -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      ensure_installed = {
          -- Scripts
          "bash", "perl", "python", "lua", "luadoc", "vim", "vimdoc", "r",
          -- Natives
          "c", "cpp", "java", "kotlin",
          -- Web
          "html", "css", "typescript", "javascript",
          -- Config
          "json", "markdown", "yaml", "toml", "po",
          -- Makefile
          "make", "cmake", "ninja",
          -- Text
          "comment", "rst",
      },

      -- Syntax highlight
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      -- Smart selection or text object selection
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          scope_incremental = '<CR>',
          node_incremental = ']',
          node_decremental = '[',
        },
        -- Report https://github.com/nvim-treesitter/nvim-treesitter/issues/2634
        is_supported = function ()
          return vim.api.nvim_get_mode().mode ~= "c"
        end
      },

      indent = {
        enable = true
      }
    }

    -- Report: https://www.reddit.com/r/neovim/comments/14n6iiy/if_you_have_treesitter_make_sure_to_disable/
    vim.opt.smartindent = false

    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt.foldenable = false
  end,
}
