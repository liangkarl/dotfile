local M = {}
local api = vim.api

IN_MAC = function()
  return vim.fn.has('macunix') == 1
end

ALT_ = function (key)
  if IN_MAC() then
    return '<M-' .. key .. '>'
  else
    return '<A-' .. key .. '>'
  end
end

M.key_is_free = function(mode, lhs)
  -- get all maps for this mode
  local maps = vim.api.nvim_get_keymap(mode)

  -- check if any map already uses this lhs
  for _, map in ipairs(maps) do
    if map.lhs == lhs then
      -- already mapped → skip
      return false
    end
  end

  return true
end

M.map = function(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.silent = opts.silent or true
  opts.desc = desc
  opts.force = opts.force or true
  if not opts.force and not M.key_is_free(mode, lhs) then
    return
  end
  opts.force = nil
  vim.keymap.set(mode, lhs, rhs, opts)
end

M.noremap = function(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.noremap = true
  opts.force = opts.force or true
  if not opts.force and not M.key_is_free(mode, lhs) then
    return
  end
  opts.force = nil
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

M.has_lsp = function(bufnr, filetype, buftype)
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  return not vim.tbl_isempty(clients)
end

M.has_treesitter = function(bufnr, filetype, buftype)
    -- Skip special buffers
  if buftype ~= "" then return false end

  local lang = vim.treesitter.language.get_lang(filetype)
  if not lang then return false end

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  return ok and parser ~= nil
end

M.nvim_version = function(cmp, str)
  str = "nvim-" .. str
  if cmp == ">" then
    return vim.version.gt(vim.version(), str)
  elseif cmp == ">=" then
    return vim.version.ge(vim.version(), str)
  elseif cmp == "<" then
    return vim.version.lt(vim.version(), str)
  elseif cmp == "<=" then
    return vim.version.le(vim.version(), str)
  end
  return vim.version.eq(vim.version(), str)
end

return M
