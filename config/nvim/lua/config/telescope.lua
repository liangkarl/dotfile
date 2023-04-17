-- Plugin: telescope.nvim
-- https://github.com/nvim-telescope/telescope.nvim

local telescope = require('telescope');

telescope.setup({
  defaults = {
    layout_strategy = 'vertical',
    layout_config = {
      vertical = {
				prompt_position = "bottom",
        preview_cutoff = 15,
				width = 0.7,
			},
    },
  },
})