-- NOTE:
-- Please refer to the link to solve the problem if you have
-- Clipboard error : Target STRING not available
-- https://github.com/gbprod/yanky.nvim/issues/46
--
return {
  "gbprod/yanky.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local picker = require('yanky.picker')
    local mapping = require("yanky.telescope.mapping")

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
          mappings = {
            default = mapping.set_register("+"),
            i = {
              ["<Tab>"] = mapping.put("p"),
              ["<S-Tab>"] = mapping.put("P"),
              ["<C-x>"] = mapping.delete(),
            },
          }, -- nil to use default mappings or no mappings (see `use_default_mappings`)
        },
      },
    })

    require('telescope').load_extension('yank_history')
  end
}
