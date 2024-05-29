return { -- setup appearance of indent, space, etc.
  -- FIXME:
  -- 1. This plugin is included in Nvim 0.9, so the config should be rewritten
  -- 2. editorconfig could be used in creating new file, and disabled in
  --    editing existed files
  'editorconfig/editorconfig-vim',
  config = function()
    -- Disable builtin editorconfig in nvim 0.9
    vim.g.editorconfig = false

    vim.g.EditorConfig_exclude_patterns = {
      'fugitive://.*',
      'scp://.*',
      'term://.*'
    }

    vim.cmd('au FileType gitcommit let b:EditorConfig_disable = 1')
  end,
  enabled = false,
}
