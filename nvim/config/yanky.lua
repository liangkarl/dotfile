-- NOTE:
-- Please refer to the link to solve the problem if you have
-- Clipboard error : Target STRING not available
-- https://github.com/gbprod/yanky.nvim/issues/46
--
return {
  "gbprod/yanky.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    keys = {
      { "<leader>p", "<cmd>YankyRingHistory<cr>", mode = { "n", "x" }, desc = "Open Yank History" },
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
    }
  },
}
