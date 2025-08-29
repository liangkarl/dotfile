return { -- A 'Swiss Army Knife' with many small features
  'echasnovski/mini.nvim',
  dependencies = { "nvim-tree/nvim-web-devicons", },
  config = function()
    local m, leader

    leader = vim.g.mapleader

    require('mini.pick').setup()
    require('mini.cursorword').setup()
    require('mini.bufremove').setup()
    -- require('mini.pairs').setup()
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

    require('mini.align').setup({
      mappings = {
        start = '',
        start_with_preview = 'c=',
      }
    })
    require('mini.surround').setup({
      mappings = {
        add = 'c[]', -- Add surrounding in Normal and Visual modes
        delete = 'd[]', -- Delete surrounding
        replace = 's[]', -- Replace surrounding (keybind[old surrounding][new surrounding])
        find = ']]', -- Find surrounding (to the right)
        find_left = '[[', -- Find surrounding (to the left)
        highlight = 's%', -- Highlight surrounding
        update_n_lines = '', -- Update `n_lines`
      },
    })
    require('mini.comment').setup({
      mappings = {
        -- Toggle comment (like `gcip` - comment inner paragraph) for both
        comment = '', -- Normal and Visual modes
        comment_line = leader .. 'cc', -- Toggle comment on current line
        comment_visual = leader .. 'cc', -- Toggle comment on visual selection
        textobject = '', -- Define 'comment' textobject (like `dgc` - delete whole comment block)
      }
    })
    require('mini.splitjoin').setup({
      mappings = {
        -- TODO: how to configure it correctly?
        toogle = leader .. 'J'
      },
    })

    -- NOTE:
    -- Low Performance when enabled in insert mode(?).
    vim.cmd([[
      " WA for default environment setup
      lua MiniTrailspace.unhighlight()
    ]])
  end
}
