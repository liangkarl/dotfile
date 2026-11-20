-- NOTE:
-- Please refer to the link to solve the problem if you have
-- Clipboard error : Target STRING not available
-- https://github.com/gbprod/yanky.nvim/issues/46
--
local keymaps = require("config.keymaps")

return {
  "gbprod/yanky.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  keys = keymaps.yanky_keys,
  config = function()
    local picker = require('yanky.picker')

    require("yanky").setup({
      ring = {
        storage = "shada",
        history_length = 50,
        sync_with_numbered_registers = true,
      },
      system_clipboard = {
        sync_with_ring = false,
      },

      picker = {
        select = {
          -- send to CopyQ/system clipboard if it is chosen
          action = picker.actions.set_register("+"),
        },
        telescope = keymaps.yanky_telescope_mappings(),
      },
    })

    require('telescope').load_extension('yank_history')
  end
}
