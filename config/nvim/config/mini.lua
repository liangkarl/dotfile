require('mini.cursorword').setup()
require('mini.bufremove').setup()
require('mini.align').setup()

local animate = require('mini.animate')
require('mini.animate').setup({
  cursor = {
    enable = false,
  },
  scroll = {
    enable = true,
    timing = animate.gen_timing.linear({ duration = 50, unit = 'total' }),
    subscroll = animate.gen_subscroll.equal({ max_output_steps = 10 }),
  }
})

--[[
-- Low Performance when enabled in insert mode.
require('mini.trailspace').setup({
  only_in_normal_buffers = true
})
--]]
