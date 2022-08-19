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

local cust_attach = function (client, bufnr)
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- If the buffer did not supported by LSP, these keymap would not take
  -- affect.
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', '<space>gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', '<space>gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', '<space>gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<space>gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>sh', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<space>s?', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<space>lf', vim.lsp.buf.formatting, bufopts)

  -- required by aerial.nvim to support LSP function
  aerial.on_attach(client, bufnr)
end

lsp.vimls.setup {
  on_attach = cust_attach,
}

-- Bash (bash-language-server)
-- https://github.com/bash-lsp/bash-language-server
lsp.bashls.setup = {}

-- Java (jdtls)
-- https://github.com/eclipse/eclipse.jdt.ls
lsp.jdtls.setup = {}

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

  on_attach = cust_attach,
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

  on_attach = cust_attach,
}

vim.keymap.set('n', '<Leader>li', ':LspInfo<CR>')

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>ge', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<space>gp', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<space>gn', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>gq', vim.diagnostic.setloclist, opts)
