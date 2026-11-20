return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- LazyVim selects a compatible revision on Neovim 0.11, including 0.11.7.
    -- Extend the parser list without overriding its branch, commit, or setup.
    opts = {
      -- UFO owns folds. Treesitter still provides highlighting and parsers.
      folds = { enable = false },
      ensure_installed = {
        "cmake",
        "comment",
        "cpp",
        "css",
        "java",
        "kotlin",
        "make",
        "ninja",
        "perl",
        "po",
        "r",
        "rst",
      },
    },
  },
}
