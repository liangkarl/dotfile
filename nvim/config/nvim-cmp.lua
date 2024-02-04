-- Enable some language servers with the additional completion capabilities
-- offered by nvim-cmp
-- LSP list:
--   ccls -> c/c++
--   rust_analyzer -> rust
--   pyright -> python
--   tsserver -> typescript

  -- autocompletion seems better in clangd, instead of ccls
  -- Try to switch multi LSP in config
  -- xavierd/clang_complete
return { -- Autocomplete framework
  'hrsh7th/nvim-cmp',
  -- load cmp on InsertEnter
  event = "InsertEnter",
  dependencies = {
    -- Snippet engine with LSP backend
    'neovim/nvim-lspconfig',
    'hrsh7th/cmp-nvim-lsp',
    'williamboman/mason-lspconfig.nvim',

    { -- Interface between nvim-cmp and luasnip
      'L3MON4D3/LuaSnip',
      build = "make install_jsregexp",
      dependencies = { "rafamadriz/friendly-snippets" },
      event = "InsertEnter",
      config = function ()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    'saadparwaiz1/cmp_luasnip',

    -- Snippet engine of buffer words
    'hrsh7th/cmp-buffer',
    { -- AI assist for completion
      'tzachar/cmp-tabnine',
      build = './install.sh',
      dependencies = { 'hrsh7th/nvim-cmp' },
      config = true
    },

    'onsails/lspkind.nvim',
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local lspkind = require('lspkind')
    local mason_lsp = require('mason-lspconfig.settings').current.ensure_installed
    local lspconfig = require('lspconfig')
    local cap = vim.lsp.protocol.make_client_capabilities()

    -- Set completeopt to have a better completion experience
    vim.o.completeopt = 'menuone,noselect'

    cap = require('cmp_nvim_lsp').default_capabilities(cap)

    cmp.setup {
      completion = { keyword_length = 1, },
      formatting = {
        format = lspkind.cmp_format({
          -- Reference: https://github.com/onsails/lspkind.nvim
          mode = 'symbol_text', -- show only symbol annotations
          maxwidth = 65, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
          ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
          show_labelDetails = true, -- show labelDetails in menu. Disabled by default
        })
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = {
        ['<C-p>'] = cmp.mapping.complete(),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ['<space>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
          cmp.close()
        else
          fallback()
        end
        end, { "i", "s" }),

        ['<cr>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
      },
      sources = {
        { name = 'cmp_tabnine' },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
      },
    }

    for _, lsp in ipairs(mason_lsp) do
      lspconfig[lsp].setup({
        -- on_attach = my_custom_on_attach,
        capabilities = cap,
      })
    end
  end,
}
