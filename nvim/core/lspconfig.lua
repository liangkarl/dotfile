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

local m = require('core.utils')

local function create_v_lsp_file()
  -- ensure lsp.log points to /tmp/lsp.log
  local state_dir = vim.fn.stdpath("state")
  local log_path = state_dir .. "/lsp.log"
  local tmp_log = "/tmp/lsp.log"

  -- make sure state dir exists
  vim.fn.mkdir(state_dir, "p")

  -- check if lsp.log already exists
  local stat = vim.loop.fs_stat(log_path)
  if not stat then
    -- create symlink if missing
    vim.loop.fs_symlink(tmp_log, log_path)
  end
end

-- FIXME: the setting would be lost if open the files within vim
local function find_compile_commands_in_buffer()
  -- Get the directory of the current file
  local file_path = vim.fn.expand('%:p')
  if file_path == "" then
    file_path = vim.api.nvim_buf_get_name(0)
  end

  if file_path == "" then
    -- print("No file found in the current buffer.")
    return ""
  end

  -- Start searching from the current file's directory
  local dir = vim.fn.fnamemodify(file_path, ":h")

  -- Loop to move up in the directory hierarchy
  while dir ~= "" do
    local compile_commands_path = dir .. "/compile_commands.json"

    -- Check if compile_commands.json exists in the current directory
    if vim.fn.filereadable(compile_commands_path) == 1 then
      -- print("Found compile_commands.json at: " .. compile_commands_path)
      return compile_commands_path
    end

    -- Move up to the parent directory
    local parent_dir = vim.fn.fnamemodify(dir, ":h")

    -- If we have reached the root directory, stop the loop
    if parent_dir == dir then
      dir = ""
      break
    end

    dir = parent_dir
  end

  -- print("compile_commands.json not found.")
  return dir
end
-- To trigger the function, you can use something like this in command mode:
-- :lua find_compile_commands_in_buffer()


return { -- LSP configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    { -- Following mason's requirements, install `mason.nvim`, `mason-lspconfig` and `nvim-lspconfig` by order
      "williamboman/mason.nvim",
      build = ":MasonUpdate", -- :MasonUpdate updates registry contents
      config = true
    },
    {
      "williamboman/mason-lspconfig.nvim",
      opts = {
        ensure_installed = {
          "lua_ls", "bashls", "vimls",
          "pyright", "html", "eslint", "ts_ls",
          "clangd"
        },
      },
    },
  },
  config = function()
    local lspconfig = require('lspconfig')
    local lsp_status = require('lsp-status')
    local lsps = require('mason-lspconfig.settings').current.ensure_installed
    local lsp = {}
    local util = require('lspconfig.util')
    local lua_ls

    for _, server in ipairs(lsps) do
      lsp[server] = {
        on_attach = lsp_status.on_attach,
        root_dir = util.root_pattern(".root", ".git"),
        root_markers = util.root_pattern(".root", ".git"),
      }
    end

    lua_ls = {
      settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            -- version = 'LuaJIT',
          },
          diagnostics = {
            -- Disable certain diagnostics globally
            disable = {"lowercase-global", "undefined-global"},
            -- Every time a file is edited, created, deleted, etc. the workspace
            -- will be re-diagnosed in the background after this delay. Setting
            -- to a negative number will disable workspace diagnostics.
            workspaceDelay = -1,
          },
          workspace = {
            checkThirdParty = false
          },
          telemetry = {
            -- Do not send telemetry data containing a randomized but unique identifier
            enable = false,
          },
        },
      },
    }

    -- Merge Table
    lsp['lua_ls'] = vim.tbl_extend("force", lsp['lua_ls'] or {}, lua_ls)

    -- customize configurations here
    -- FIXME: The LSP setting would lose after changing from insert mode to insert mode

    -- initialize basic configurations for LSP servers installed by mason
    for _, server in ipairs(lsps) do
      lspconfig[server].setup(lsp[server])
    end

    -- configurations for external installation of LSP
    -- C/C++/Obj-C (ccls)
    -- https://github.com/MaskRay/ccls
    -- lspconfig['ccls'].setup {
    --   init_options = {
    --     -- compilationDatabaseDirectory = "";
    --     cache = {
    --       directory = vim.env.XDG_DATA_HOME
    --           and vim.env.XDG_DATA_HOME .. "/ccls/cache"
    --           or ".ccls-cache",
    --     },
    --     client = {
    --       snippetSupport = true,
    --     },
    --     index = {
    --       threads = 0,
    --       onChange = false,
    --     },
    --     diagnostics = {
    --       onChange = -1,
    --     },
    --     compilationDatabaseDirectory = find_compile_commands_in_buffer()
    --   },
    -- }

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    -- m.autocmd('LspAttach', '*', function(ev)
    --   -- Enable completion triggered by <c-x><c-o>
    --   vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    -- end, {
    --   group = m.augroup('UserLspConfig'),
    -- })
    vim.lsp.set_log_level("off")
    create_v_lsp_file()
  end,
}
