-- Plugin: tig-explorer.vim
-- https://github.com/iberianpig/tig-explorer.vim

-- As the offical guide said, tig-explorer depends on the plugin, bclose,
-- which is an really old plugin.
-- command! -bang -nargs=1 -complete=buffer Bclose bdelete! <f-args>

vim.cmd([[
  command! -bang -nargs=1 -complete=buffer Bclose lua require('myplugin').close_buffer(<f-args>)
]])

-- 在你的 Lua 插件文件中定义 close_buffer 函数
local myplugin = {}

function myplugin.close_buffer(arg)
  -- 执行关闭缓冲区的操作
  local bufnr = vim.fn.bufnr(arg)
  if bufnr ~= -1 then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

return myplugin
