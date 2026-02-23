-- Plugin: lualine.nvim
-- https://github.com/nvim-lualine/lualine.nvim

local function macro_recording()
  local reg = vim.fn.reg_recording()
  if reg == "" then return "" end
  return "REC @" .. reg
end

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
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
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
        lualine_c = {
          {
            'tabs',
            mode = 1,
            use_mode_colors = true,
            show_modified_status = false,
            fmt = function(name, context)
              local tabnr = context.tabnr
              local ok, t = pcall(function() return vim.t[tabnr] end)
              local name = (ok and t and t.name) or '*'
              return tabnr .. ':' .. name
            end
          },
          { 'filename', path = 1, symbols = { modified = '[M]', readonly = '[RO]' }},
          { macro_recording, color = "Macro" },
        },
        lualine_x = { 'searchcount', 'encoding', 'fileformat', 'filetype', 'lsp_status' },
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
