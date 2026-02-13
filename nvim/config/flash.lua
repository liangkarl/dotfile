return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    modes = {
      search = {
        enabled = true, -- 讓 / ? 搜尋時自動出現 flash labels
        -- 這裡不寫也行，因為預設 search mode 就是 nohlsearch=true
        jump = { nohlsearch = true },
      },
    },
  },
  keys = {
    -- { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    -- { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    -- { "<leader>rr", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    -- { "<leader>RR", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
