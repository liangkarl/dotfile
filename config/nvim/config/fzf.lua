-- Plugin: fzf

-- Plugin: fzf - fuzzy finder
-- e.g. let g:fzf_command_prefix = 'Fzf' and you have FzfFiles, etc.
vim.g.fzf_command_prefix = 'Fzf'

vim.cmd('nnoremap <leader>ff :FzfFiles<cr>')
vim.cmd('nnoremap <leader>fb :FzfBuffers<cr>')
vim.cmd('nnoremap <leader>fr :FzfHistory<cr>')
vim.cmd('nnoremap <leader>f? :FzfMaps<cr>')
vim.cmd('nnoremap <leader>fe :FzfFiletypes<cr>')
vim.cmd('nnoremap <leader>fh :FzfHelptags<cr>')

vim.cmd('nnoremap <leader>fc :FzfBCommits<cr>')
vim.cmd('nnoremap <leader>fC :FzfCommits<cr>')
vim.cmd('nnoremap <leader>fs :FzfGFiles?<cr>')
vim.cmd("nnoremap <leader>fg :exe 'FzfRg' expand('<cword>>')<cr>")
vim.cmd('nnoremap <leader>fG :FzfRg<cr>')

-- disable case insensitive
-- command! -bang -nargs=* Rg
--   \ call fzf#vim#grep(
--   \   'rg --column --line-number --no-heading --color=always -- '.shellescape(<q-args>), 1,
--   \   fzf#vim#with_preview(), <bang>0)

-- | Command                | List                                                                                  |
-- | ---                    | ---                                                                                   |
-- | `:Files [PATH]`        | Files (runs `$FZF_DEFAULT_COMMAND` if defined)                                        |
-- | `:GFiles [OPTS]`       | Git files (`git ls-files`)                                                            |
-- | `:GFiles?`             | Git files (`git status`)                                                              |
-- | `:Buffers`             | Open buffers                                                                          |
-- | `:Colors`              | Color schemes                                                                         |
-- | `:Ag [PATTERN]`        | [ag][ag] search result (`ALT-A` to select all, `ALT-D` to deselect all)               |
-- | `:Rg [PATTERN]`        | [rg][rg] search result (`ALT-A` to select all, `ALT-D` to deselect all)               |
-- | `:Lines [QUERY]`       | Lines in loaded buffers                                                               |
-- | `:BLines [QUERY]`      | Lines in the current buffer                                                           |
-- | `:Tags [QUERY]`        | Tags in the project (`ctags -R`)                                                      |
-- | `:BTags [QUERY]`       | Tags in the current buffer                                                            |
-- | `:Marks`               | Marks                                                                                 |
-- | `:Windows`             | Windows                                                                               |
-- | `:Locate PATTERN`      | `locate` command output                                                               |
-- | `:History`             | `v:oldfiles` and open buffers                                                         |
-- | `:History:`            | Command history                                                                       |
-- | `:History/`            | Search history                                                                        |
-- | `:Snippets`            | Snippets ([UltiSnips][us])                                                            |
-- | `:Commits [LOG_OPTS]`  | Git commits (requires [fugitive.vim][f])                                              |
-- | `:BCommits [LOG_OPTS]` | Git commits for the current buffer; visual-select lines to track changes in the range |
-- | `:Commands`            | Commands                                                                              |
-- | `:Maps`                | Normal mode mappings                                                                  |
-- | `:Helptags`            | Help tags <sup id="a1">[1](#helptags)</sup>                                           |
-- | `:Filetypes`           | File types                                                                            |

