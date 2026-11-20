return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = { virtual_text = false },
      servers = {
        bashls = {},
        clangd = {},
        eslint = {},
        html = {},
        pyright = {},
        ts_ls = {},
        vimls = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                disable = { "lowercase-global", "undefined-global" },
                workspaceDelay = -1,
              },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
      },
    },
  },
}
