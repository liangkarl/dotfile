-- init.lua


-- Plugin: treesitter
local treesitter = require'nvim-treesitter.configs'
treesitter.setup {
  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {"bash", "c", "cpp", "go", "html", "java", "javascript",
                      "json", "kotlin", "latex", "lua", "ocaml", "python",
                      "r", "rst", "rust", "toml", "typescript", "vim", "yaml"},
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

-- Plugin: lspconfig
local lspconfig = require'lspconfig'
lspconfig.ccls.setup {
  init_options = {
    compilationDatabaseDirectory = "build";
    cache = {
      directory = ".ccls-cache";
    };
    client = {
      snippetSupport = true;
    };
    index = {
      threads = 0;
      onChange = true;
    };
    clang = {
      excludeArgs = { "-frounding-math"} ;
    };
  }
}
