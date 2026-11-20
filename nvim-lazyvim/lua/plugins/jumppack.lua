local keymaps = require("config.keymaps")

return {
  'suliatis/Jumppack.nvim',
  opts = { mappings = keymaps.jumppack_mappings },
  config = true,
}
