" Plugin: editorconfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*', 'term://.*']
au FileType gitcommit let b:EditorConfig_disable = 1
