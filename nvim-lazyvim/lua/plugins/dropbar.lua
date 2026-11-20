return {
  'Bekaboo/dropbar.nvim',
  -- optional, but required for fuzzy finder support
  dependencies = {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- build = 'make'
  },
  config = function()
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
