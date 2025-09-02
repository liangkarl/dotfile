return { -- A 'Swiss Army Knife' with many small features
  'echasnovski/mini.nvim',
  dependencies = { "nvim-tree/nvim-web-devicons", },
  config = function()
    local m, leader

    leader = vim.g.mapleader

    require('mini.cursorword').setup()
    require('mini.bufremove').setup()
    require('mini.align').setup({
      mappings = {
        start = '',
        start_with_preview = '>=',
      }
    })
    -- require('mini.pairs').setup()
    require('mini.surround').setup({
      mappings = {
        add = leader .. 'cs', -- Add surrounding in Normal and Visual modes
        delete = leader .. 'cd', -- Delete surrounding
        replace = leader .. 'cS', -- Replace surrounding (keybind[old surrounding][new surrounding])
        find = 'g]', -- Find surrounding (to the right)
        find_left = 'g[', -- Find surrounding (to the left)
        highlight = 'sv', -- Highlight surrounding
        update_n_lines = '', -- Update `n_lines`
      },
    })
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

    require('mini.comment').setup({
      mappings = {
        -- Toggle comment (like `gcip` - comment inner paragraph) for both
        -- Normal and Visual modes
        comment = '',
        -- Toggle comment on current line
        comment_line = 'cg',
        -- Toggle comment on visual selection
        comment_visual = 'cg',
        -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        textobject = '',
      }
    })

    -- NOTE:
    -- Low Performance when enabled in insert mode(?).
    vim.cmd([[
      " WA for default environment setup
      lua MiniTrailspace.unhighlight()
    ]])
  end
}
