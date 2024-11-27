local m = require('core.utils')
local gid = m.augroup('StickybufCtrl')

return {
  'stevearc/stickybuf.nvim',
  config = function()
    local s = require('stickybuf')

    s.setup({})

    m.autocmd("BufAdd", "*", function()
        if vim.bo.modifiable then
          return
        end

        if not s.is_pinned()
            and vim.bo.filetype ~= "startify" then -- FIXME: WA for Startify here
          s.pin()
        end
      end, {
        desc = "Pin non-modifiable buffers",
        group = gid
    })

    m.autocmd("BufDelete", "*", function()
        if vim.bo.modifiable then
          return
        end

        if s.is_pinned() then
          s.unpin()
        end
      end, {
        desc = "Unpin non-modifiable buffers",
        group = gid
    })
  end
}
