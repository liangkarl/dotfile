local animate

require('mini.cursorword').setup()
require('mini.bufremove').setup()
require('mini.align').setup()

require('mini.files').setup({
  window = {
    preview = true
  }
})

animate = require('mini.indentscope').gen_animation
require('mini.indentscope').setup({
  draw = {
    delay = 50,
    animation = animate.none()
  }
})
require('mini.pairs').setup()

animate = require('mini.animate')
require('mini.animate').setup({
  scroll = {
    enable = true,
    timing = animate.gen_timing.linear({ duration = 5, unit = 'step' }),
    subscroll = animate.gen_subscroll.equal({ max_output_steps = 4 }),
  },
  cursor = {
    enable = false,
    timing = animate.gen_timing.none(),
  },
  resize = {
    enable = false,
    timing = animate.gen_timing.none(),
  },
  open = {
    enable = false,
    timing = animate.gen_timing.none(),
  },
  close = {
    enable = false,
    timing = animate.gen_timing.none(),
  },
})

-- NOTE:
-- Low Performance when enabled in insert mode(?).
require('mini.trailspace').setup({ only_in_normal_buffers = true })
vim.cmd([[
  " WA for default environment setup
  lua MiniTrailspace.unhighlight()
  " Remove trailing whitespace
  nnoremap <silent><leader>ss :lua MiniTrailspace.trim()<cr>
  nnoremap <silent><leader>ft :lua MiniFiles.open()<cr>
]])
