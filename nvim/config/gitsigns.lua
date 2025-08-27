return { -- show diff symbols aside via git diff
  'lewis6991/gitsigns.nvim',
  event = "VeryLazy",
  config = function()
    require('gitsigns').setup({
      current_line_blame_formatter = '[ <abbrev_sha> | <author> | <author_time:%m/%d/%y %X> | <summary> ]'
    })
  end,
}
