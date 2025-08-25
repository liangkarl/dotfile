local M = {}
local api = vim.api

M.map = function(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.silent = opts.silent or true
  opts.desc = desc
  vim.keymap.set(mode, lhs, rhs, opts)
end

M.noremap = function(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.noremap = true
  M.map(mode, lhs, rhs, desc, opts)
end

M.autocmd = function(event, pattern, action, opts)
  opts = opts or {}

  opts.pattern = pattern
  if type(action) == "string" then
    opts.command = action
  else
    opts.callback = action
  end

  return api.nvim_create_autocmd(event, opts)
end

M.augroup = function(name, opts)
  opts = opts or {}
  opts.clear = opts.clear or true
  return api.nvim_create_augroup(name, opts)
end

M.highlight = function(name, opts)
  opts = opts or {}
  return api.nvim_set_hl(opts.buffer or 0, name, opts)
end

M.command = function(cmd, action, opts)
  opts = opts or {}
  opts.bang = opts.bang or true
  return api.nvim_create_user_command(cmd, action, opts)
end

M.run_once = function(name, fn)
  local post_install_file = vim.fn.stdpath("data") .. "/post_installs/" .. name

  if vim.fn.filereadable(post_install_file) == 1 then
    return
  end

  fn()

  -- Create directory if it doesn't exist
  vim.fn.mkdir(vim.fn.fnamemodify(post_install_file, ":h"), "p")

  -- Create empty file
  local file = io.open(post_install_file, "w")
  file:close()
end

M.run_if_exits = function(cmd)


end

return M
