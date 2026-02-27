return {
  'Bekaboo/dropbar.nvim',
  -- optional, but required for fuzzy finder support
  dependencies = {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- build = 'make'
  },
  config = function()
    local dropbar_api = require('dropbar.api')
    -- vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
    -- vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
    -- vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    require('dropbar').setup({
      bar = {
        sources = function(buf, _)
          local sources = require('dropbar.sources')
          local utils = require('dropbar.utils')
          if vim.bo[buf].ft == 'markdown' then
            return {
              sources.markdown,
            }
          end
          if vim.bo[buf].buftype == 'terminal' then
            return {
              sources.terminal,
            }
          end
          -- 一般檔案：只用 LSP / Treesitter 的符號來源（不含 path）
          return {
            -- 只顯示檔名
            {
              get_symbols = function(buf, win, cursor)
                local symbols = sources.path.get_symbols(buf, win, cursor)
                if symbols and #symbols > 0 then
                  -- 只保留最後一個，也就是檔案名稱
                  symbols = { symbols[#symbols] }
                end
                return symbols
              end,
            },
            utils.source.fallback({
              sources.treesitter,
            }),
          }
        end,
      },
    })
  end
}
