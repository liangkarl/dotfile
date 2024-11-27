return {
  'nvim-lua/lsp-status.nvim',
  config = function()
    local lsp_status = require('lsp-status')
    local m = require('core.utils')

    lsp_status.config({
      -- Avoid using use emoji-like or full-width characters
      -- because it can often break rendering within tmux and some terminals
      -- See $VIMPLUG/lsp-status.nvim/lua/lsp-status.lua
      indicator_hint = '!',
      status_symbol = ' ',

      -- If true, automatically sets b:lsp_current_function
      -- (no longer used in favor of treesitter + nvim-gps)
      current_function = true,
      diagnostics = false,
    })

    -- WA: Update current function
    m.autocmd({ "CursorMoved", "CursorMovedI" }, "*",
      function()
        if #vim.lsp.get_active_clients({bufnr = 0}) > 0 then
          lsp_status.update_current_function()
        end
      end, {
      group = m.augroup("LspStatupUpdate")
    })

    -- LspStatus(): status string for lualine
    -- _G.LspStatus = function()
    --   if #vim.lsp.get_active_clients({bufnr = 0}) > 0 then
    --     return require('lsp-status').status()
    --   end
    --   return ''
    -- end
    --
    -- -- :LspStatus (command): display lsp status
    -- vim.cmd([[
    --   command! -nargs=0 LspStatus echom v:lua.LspStatus()
    -- ]])
  end
}
