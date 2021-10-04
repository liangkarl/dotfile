-- init.lua

-- Plugin: nvim-tree
-- https://github.com/kyazdani42/nvim-tree.lua
require('nvim-tree').setup {
	auto_close = true,
	update_to_buf_dir = {
		enable = true,
		auto_open = true,
	},
	update_cwd = true,
	auto_close = true,
}
vim.g.nvim_tree_special_files = {
      Makefile = true,
	  ["Android.mk"] = true,
	  ["Kconfig"] = true,
      ["README.md"] = true,
      ["readme.md"] = true,
}
vim.g.nvim_tree_quit_on_open = 1
vim.g.nvim_tree_hide_dotfiles = 1
vim.g.nvim_tree_icon_padding = ' '

-- Plugin: which-key
-- https://github.com/folke/which-key.nvim
-- Run ':checkhealth which_key' to see if there's any conflicting
-- keymaps that will prevent triggering WhichKey
require("which-key").setup {}

-- Plugin: nvim-tree.lua
-- default will show icon by default if no icon is provided
-- default shows no icon by default
vim.g.nvim_tree_icons = {
	default = "",
	symlink = "",
	git = {
		unstaged = "✗",
		staged = "✓",
		unmerged = "",
		renamed = "➜",
		untracked = "★",
		deleted = "",
		ignored = "◌"
	},
	folder = {
		arrow_open = "",
		arrow_closed = "",
		default = "",
		open = "",
		empty = "",
		empty_open = "",
		symlink = "",
		symlink_open = "",
	},
	lsp = {
		hint = "",
		info = "",
		warning = "",
		error = "",
	}
 }

-- Plugin: symbols-outline
vim.g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = true,
    position = 'right',
    width = 25,
    show_numbers = false,
    show_relative_numbers = false,
    show_symbol_details = true,
    keymaps = { -- These keymaps can be a string or a table for multiple keys
        close = {"<Esc>", "q"},
        goto_location = "<Cr>",
        focus_location = "o",
        hover_symbol = "<C-space>",
        toggle_preview = "K",
        rename_symbol = "r",
        code_actions = "a",
    },
    lsp_blacklist = {},
    symbol_blacklist = {},
    symbols = {
        File = {icon = "", hl = "TSURI"},
        Module = {icon = "", hl = "TSNamespace"},
        Namespace = {icon = "", hl = "TSNamespace"},
        Package = {icon = "", hl = "TSNamespace"},
        Class = {icon = "𝓒", hl = "TSType"},
        Method = {icon = "ƒ", hl = "TSMethod"},
        Property = {icon = "", hl = "TSMethod"},
        Field = {icon = "", hl = "TSField"},
        Constructor = {icon = "", hl = "TSConstructor"},
        Enum = {icon = "ℰ", hl = "TSType"},
        Interface = {icon = "ﰮ", hl = "TSType"},
        Function = {icon = "", hl = "TSFunction"},
        Variable = {icon = "", hl = "TSConstant"},
        Constant = {icon = "", hl = "TSConstant"},
        String = {icon = "𝓐", hl = "TSString"},
        Number = {icon = "#", hl = "TSNumber"},
        Boolean = {icon = "⊨", hl = "TSBoolean"},
        Array = {icon = "", hl = "TSConstant"},
        Object = {icon = "⦿", hl = "TSType"},
        Key = {icon = "🔐", hl = "TSType"},
        Null = {icon = "NULL", hl = "TSType"},
        EnumMember = {icon = "", hl = "TSField"},
        Struct = {icon = "𝓢", hl = "TSType"},
        Event = {icon = "🗲", hl = "TSType"},
        Operator = {icon = "+", hl = "TSOperator"},
        TypeParameter = {icon = "𝙏", hl = "TSParameter"}
    }
}

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

-- Plugin: nvim-cmp
-- https://github.com/hrsh7th/nvim-cmp/
require('nvim-cmp')
