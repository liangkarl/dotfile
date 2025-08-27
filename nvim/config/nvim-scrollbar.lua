return {
  'petertriho/nvim-scrollbar',
  config = function()
    local mod = require("scrollbar")
    mod.setup({
      handlers = {
        cursor = false,
        diagnostic = false,
      },
      handle = {
        blend = 0,
      }
    })
  end,
}
