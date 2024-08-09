-- Plugin: Startify
-- Show startify when there is no opened buffers

local function show_startify()
  local tabpage_bufs = vim.api.nvim_tabpage_list_bufs(0)
  if #vim.tbl_filter(function(buf)
    return not vim.api.nvim_buf_is_loaded(buf) or not vim.api.nvim_buf_get_option(buf, 'buflisted')
  end, tabpage_bufs) == 0 and vim.fn.bufname('') == '' then
    vim.cmd('Startify')
  end
end

return {
  'mhinz/vim-startify',
  config = function()
    -- FIXME: There is an error when open :help pages
    -- vim.cmd([[autocmd! BufDelete * lua show_startify()]])
  end
}
