return {
  {
    "saghen/blink.cmp",
    dependencies = {
      {
        "Exafunction/windsurf.nvim",
        main = "codeium",
        cmd = "Codeium",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
          enable_cmp_source = false,
          virtual_text = { enabled = false },
        },
      },
    },
    opts = {
      sources = {
        default = { "codeium" },
        providers = {
          codeium = { name = "Codeium", module = "codeium.blink", async = true },
        },
      },
    },
  },
}
