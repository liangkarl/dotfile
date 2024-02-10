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

local m = require('helpers.utils')

return { -- LSP configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = {
        { -- Following mason's requirements, install `mason.nvim`, `mason-lspconfig` and `nvim-lspconfig` by order
          "williamboman/mason.nvim",
          build = ":MasonUpdate", -- :MasonUpdate updates registry contents
          config = true
        },
      },
      opts = {
        ensure_installed = {
          "lua_ls", "bashls", "vimls",
          "clangd", "jdtls",
          "pyright", "html", "tsserver"
        },
      },
    },
  },
  config = function()
    local lspconfig = require('lspconfig')
    local lsp_status = require('lsp-status')
    local mason_lsp = require('mason-lspconfig.settings').current.ensure_installed
    local conf_tbl = {}

    for _, server in ipairs(mason_lsp) do
      conf_tbl[server] = {
        on_attach = lsp_status.on_attach,
      }
    end

    -- customize configurations here
    conf_tbl['lua_ls'] = {
      settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim' },
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

    -- initialize basic configurations for LSP servers installed by mason
    for _, server in ipairs(mason_lsp) do
      lspconfig[server].setup(conf_tbl[server])
    end

    -- configurations for external installation of LSP
    -- C/C++/Obj-C (ccls)
    -- https://github.com/MaskRay/ccls
    lspconfig['ccls'].setup {
      init_options = {
        -- compilationDatabaseDirectory = "";
        cache = {
          directory = ".ccls-cache",
        },
        client = {
          snippetSupport = true,
        },
        index = {
          threads = 0,
          onChange = true,
        },
        clang = {
          excludeArgs = { "-frounding-math" },
        },
      },
    }

    m.noremap('n', '<leader>li', '<cmd>LspInfo<cr>', "LSP: LSP Server Status")
    m.noremap('n', '<leader>ms', '<cmd>Mason<cr>', "LSP: Open Mason")

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    m.autocmd('LspAttach', '*', function(ev)
      local lspb = vim.lsp.buf

      -- Improve format codes
      m.noremap({ 'n', 'v' }, '<space>=', function() lspb.format({ async = true }) end, "LSP: Format code")
      -- Enable completion triggered by <c-x><c-o>
      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

      m.noremap('n', '<space>lv', lspb.hover, "LSP: Show info")
      m.noremap('n', '<space>lh', lspb.signature_help, "LSP: Show signatures")
      m.noremap('n', '<space>la', lspb.add_workspace_folder, "LSP: Add workspace")
      m.noremap('n', '<space>lm', lspb.remove_workspace_folder, "LSP: Remove workspace")
      m.noremap('n', '<leader>ls', function()
        print(vim.inspect(lspb.list_workspace_folders()))
      end, "LSP: Show workspace")

      m.noremap('n', '<space>rn', lspb.rename, "LSP: Rename var/func")
      m.noremap({ 'n', 'v' }, '<space>lc', lspb.code_action, "LSP: Show code action menu")
    end, {
      group = m.augroup('UserLspConfig'),
    })
  end,
}
