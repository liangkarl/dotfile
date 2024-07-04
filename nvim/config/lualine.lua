-- Plugin: lualine.nvim
-- https://github.com/nvim-lualine/lualine.nvim

return { -- Status line (button)
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-lua/lsp-status.nvim',
  },
  config = function()
    local lualine = require('lualine')

    lualine.setup {
      options = {
        icons_enabled = true,
        theme = 'powerline',
        -- component_separators = { left = '', right = ''},
        -- section_separators = { left = '', right = ''},
        component_separators = {},
        section_separators = {},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'searchcount', "require('lsp-status').status():gsub('%%', '%%%%')", 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      -- keep empty for bufferline.nvim
      tabline = {},

      winbar = {},
      inactive_winbar = {},
      extensions = {
        'aerial', 'symbols-outline', -- symbol manager
        'quickfix', 'man',       -- built-in windows
        'fzf',                   -- fuzzy finder
        'nvim-tree',             -- file explorer
        'toggleterm',            -- terminal
        'trouble'                -- lsp hint
      }
    }
  end
}
