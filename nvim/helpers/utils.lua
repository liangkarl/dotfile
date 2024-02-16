local M = {}

M.map = function(mode, lhs, rhs, desc, opt)
  local opts = opt or {}

  opts.silent = true
  opts.desc = desc
  vim.keymap.set(mode, lhs, rhs, opts)
end

M.noremap = function(mode, lhs, rhs, desc, opt)
  local opts = opt or {}

  opts.noremap = true
  M.map(mode, lhs, rhs, desc, opts)
end

M.autocmd = function(event, pattern, action, opt)
  local opts = opt or {}

  opts.pattern = pattern
  if type(action) == "string" then
    opts.command = action
  else
    opts.callback = action
  end

  return vim.api.nvim_create_autocmd(event, opts)
end

M.augroup = function(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

M.highlight = function(name, opts)
  return vim.api.nvim_set_hl(0, name, opts)
end

return M