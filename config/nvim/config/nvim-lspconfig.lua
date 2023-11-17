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

lsp.vimls.setup({})

-- Bash (bash-language-server)
-- https://github.com/bash-lsp/bash-language-server
lsp.bashls.setup({})

-- Java (jdtls)
-- https://github.com/eclipse/eclipse.jdt.ls
lsp.jdtls.setup({})

-- C/C++/Obj-C (ccls)
-- https://github.com/MaskRay/ccls
lsp.ccls.setup {
  init_options = {
    -- compilationDatabaseDirectory = "";
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
}

-- Lua (sumneko_lua)
-- https://github.com/sumneko/lua-language-server
lsp.lua_ls.setup {
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
        checkThirdParty = false
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

vim.keymap.set('n', '<leader>li', ':LspInfo<cr>')

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>ge', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<space>gp', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<space>gn', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>gq', vim.diagnostic.setloclist, opts)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', '<space>gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<space>gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<space>gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<space>gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<space>lf', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
