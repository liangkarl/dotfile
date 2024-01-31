local m = require('helpers.utils')

return { -- Symbol Manager
  'hedyhli/outline.nvim',
  config = function()
    require('outline').setup({
      symbols = {
        filter = {
          "Class",
          "Function",
          "Module",
          "Method",
          "Struct",
        },
      }
    })

    m.noremap('n', '<leader>sm', '<cmd>Outline<cr>', 'Toggle Outline Symbol Manager')
    m.noremap('n', '<leader>si', '<cmd>OutlineStatus<cr>', 'Get Outline Symbol Manager info')
  end
}
