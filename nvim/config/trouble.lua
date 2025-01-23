return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local actions = require("telescope.actions")
    local open_with_trouble = require("trouble.sources.telescope").open

    -- Use this to add more results without clearing the trouble list
    local add_to_trouble = require("trouble.sources.telescope").add

    -- TODO:
    -- Similar keybinds should move to somewhere else, otherwise it would
    -- override the previous settings
    -- local telescope = require("telescope")
    --
    -- telescope.setup({
    --   defaults = {
    --     mappings = {
    --       i = { ["<c-t>"] = open_with_trouble },
    --       n = { ["<c-t>"] = open_with_trouble },
    --     },
    --   },
    -- })

    require("trouble").setup()
  end
}
