return {
  'nmac427/guess-indent.nvim',
  config = function()
    require('guess-indent').setup({
      auto_cmd = false,
      override_editor = false,
    })
  end,
}
