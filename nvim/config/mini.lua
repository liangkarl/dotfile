return { -- A 'Swiss Army Knife' with many small features
  'echasnovski/mini.nvim',
  dependencies = { "nvim-tree/nvim-web-devicons", },
  config = function()
    local m, leader

    require('mini.cursorword').setup()
    require('mini.bufremove').setup()
    require('mini.align').setup()
    require('mini.pairs').setup()
    require('mini.surround').setup()
    require('mini.notify').setup({
      window = {
        config = {
          height = 5
        }
      }
    })

    m = require('mini.indentscope')
    m.setup({
      draw = {
        delay = 0,
        animation = m.gen_animation.none()
      }
    })

    require('mini.files').setup({
      windows = {
        preview = true,
        -- Following Linux Kernel guideline, the max length for a line is 80 chars
        width_preview = 80,
      }
    })

    require('mini.trailspace').setup({ only_in_normal_buffers = true })

    leader = vim.g.mapleader
    require('mini.comment').setup({
      mappings = {
        -- Toggle comment (like `gcip` - comment inner paragraph) for both
        -- Normal and Visual modes
        comment = leader .. 'gb',

        -- Toggle comment on current line
        comment_line = leader .. 'gg',

        -- Toggle comment on visual selection
        comment_visual = leader .. 'gg',

        -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        textobject = leader .. 'gb',
      }
    })

    m = require('helpers.utils')
    m.noremap('n', '<leader>ft', '<cmd>lua MiniFiles.open()<cr>', 'Open FileExplorer')
    m.noremap('n', '<leader>ss', '<cmd>lua MiniTrailspace.trim()<cr>', 'Remove trailing spaces')

    -- NOTE:
    -- Low Performance when enabled in insert mode(?).
    vim.cmd([[
      " WA for default environment setup
      lua MiniTrailspace.unhighlight()
    ]])
  end
}
