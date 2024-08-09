return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      api_key_cmd = "echo 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"
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim"
  },
  enabled = false,
}
