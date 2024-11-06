local m = require('helpers.utils')

return {
  'anuvyklack/fold-preview.nvim',
  dependencies = {
    'anuvyklack/keymap-amend.nvim'
  },
  config = function()
    local preview = require('fold-preview')
    preview.setup({
      auto = false,
      default_keybindings = true,
    })
    -- m.noremap('n', 'zp', function() preview.toggle_preview() end,
    --   "Toggle folding preview")
  end
}
