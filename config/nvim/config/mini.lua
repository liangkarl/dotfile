require('mini.cursorword').setup()
require('mini.bufremove').setup()
require('mini.align').setup()
require('mini.pairs').setup()

local m

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
  window = {
    preview = true
  }
})

require('mini.trailspace').setup({
  only_in_normal_buffers = true
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
