-- Plugin: lsp-config
-- TODO:
-- 1. debug LSP
-- 4. Use K to show documentation in preview window.
-- 5. Symbol renaming.
-- 6. Formatting selected code.
-- 7. Apply AutoFix to problem on the current line.

-- 9. NeoVim-only mapping for visual mode scroll
-- Useful on signatureHelp after jump placeholder of snippet expansion

-- 10. Add (Neo)Vim's native statusline support.
-- NOTE: Please see `:h coc-status` for integrations with external plugins that
-- provide custom statusline: lightline.vim, vim-airline.

-- 11. gd will go by coc -> tags -> searchdecl
-- go to type def
-- go to impl
-- go to reference
--

-- Configure LSP server
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

local lsp = require('lspconfig')
local aerial = require('aerial')

-- required by aerial.nvim to support LSP function
lsp.vimls.setup {
  on_attach = aerial.on_attach,
}

-- Bash (bash-language-server)
-- https://github.com/bash-lsp/bash-language-server
lsp.bashls.setup = {}

-- C/C++/Obj-C (ccls)
-- https://github.com/MaskRay/ccls
lsp.ccls.setup {
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
  },

  on_attach = aerial.on_attach,
}

-- Lua (sumneko_lua)
-- https://github.com/sumneko/lua-language-server
lsp.sumneko_lua.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },

  on_attach = aerial.on_attach,
}

vim.keymap.set('n', '<Leader>li', ':LspInfo<CR>')
