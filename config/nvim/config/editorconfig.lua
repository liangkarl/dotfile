-- Plugin: editorconfig

vim.g.EditorConfig_exclude_patterns = {
  'fugitive://.*',
  'scp://.*',
  'term://.*'
}

vim.cmd('au FileType gitcommit let b:EditorConfig_disable = 1')
