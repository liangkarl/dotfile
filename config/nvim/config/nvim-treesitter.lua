-- nvim-treesitter/nvim-treesitter:
-- https://github.com/nvim-treesitter/nvim-treesitter
--
-- The goal of nvim-treesitter is both to provide a simple and easy way
-- to use the interface for tree-sitter in Neovim and to provide some
-- basic functionality such as highlighting based on it

local treesitter = require('nvim-treesitter.configs')
treesitter.setup {
  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {"bash", "perl", "python", "lua", "luadoc", "vim", "vimdoc", "r",
                      "c", "cpp", "c_sharp", "rust", "go", "java", "kotlin",
                      "html", "css", "typescript", "javascript",
                      "json", "markdown", "yaml", "toml",
                      "make", "cmake", "ninja",
                      "comment", "rst"},
  ignore_install = { "javascript" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = {},  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
