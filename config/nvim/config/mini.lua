require('mini.cursorword').setup()
require('mini.bufremove').setup()
require('mini.align').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.notify').setup()

local m, leader

leader = vim.g.mapleader

m = require('mini.indentscope')
m.setup({
  draw = {
    delay = 50,
    animation = m.gen_animation.none()
  }
})

m = require('mini.animate')
m.setup({
  scroll = {
    enable = true,
    timing = m.gen_timing.linear({
      duration = 5,
      unit = 'step'
    }),
    subscroll = m.gen_subscroll.equal({
      max_output_steps = 4
    }),
  },
  cursor = { enable = false, },
  resize = { enable = false, },
  open = { enable = false, },
  close = { enable = false, },
})

require('mini.files').setup({
  windows = {
    preview = true,
    -- Following Linux Kernel guideline, the max length for a line is 80 chars
    width_preview = 80,
  }
})

require('mini.trailspace').setup({
  only_in_normal_buffers = true
})

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

-- NOTE:
-- Low Performance when enabled in insert mode(?).
vim.cmd([[
  " WA for default environment setup
  lua MiniTrailspace.unhighlight()
  " Remove trailing whitespace
  nnoremap <silent><leader>ss :lua MiniTrailspace.trim()<cr>
  nnoremap <silent><leader>ft :lua MiniFiles.open()<cr>
]])
