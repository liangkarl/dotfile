-- NOTE:
-- Please refer to the link to solve the problem if you have
-- Clipboard error : Target STRING not available
-- https://github.com/gbprod/yanky.nvim/issues/46
--
return {
  "gbprod/yanky.nvim",
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
        telescope = {
          use_default_mappings = true, -- if default mappings should be used
          mappings = nil, -- nil to use default mappings or no mappings (see `use_default_mappings`)
        },
      },
    })
  end
}
