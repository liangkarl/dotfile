local animate

require('mini.cursorword').setup()
require('mini.bufremove').setup()
require('mini.align').setup()

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
  cursor = {
    enable = false,
  },
  scroll = {
    enable = true,
    timing = animate.gen_timing.linear({ duration = 10, unit = 'step' }),
    subscroll = animate.gen_subscroll.equal({ max_output_steps = 5 }),
  }
})

--[[
-- Low Performance when enabled in insert mode.
require('mini.trailspace').setup({
  only_in_normal_buffers = true
})
--]]
