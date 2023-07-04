-- Plugin: telescope.nvim
-- https://github.com/nvim-telescope/telescope.nvim

if not pcall(require, "telescope") then
  return
end

local telescope = require('telescope')
local opts = { noremap=true, silent=true }

telescope.setup({
  defaults = {
    layout_strategy = 'vertical',
    layout_config = {
      vertical = {
        prompt_position = "bottom",
        preview_cutoff = 15,
        width = 0.7,
      },
    },
  },
})

-- Find files using Telescope command-line sugar.
vim.keymap.set('n', '<leader>fs', '<cmd>Telescope<cr>', opts)
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope oldfiles<cr>', opts)
vim.keymap.set('n', '<leader>fF', '<cmd>Telescope find_files<cr>', opts)
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope grep_string<cr>', opts)
vim.keymap.set('n', '<leader>fG', '<cmd>Telescope live_grep<cr>', opts)
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
vim.keymap.set('n', '<leader>fr', '<cmd>Telescope registers<cr>', opts)
vim.keymap.set('n', '<leader>f?', '<cmd>Telescope keymaps<cr>', opts)
vim.keymap.set('n', '<leader>fe', '<cmd>Telescope filetypes<cr>', opts)
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)

-- ### File Pickers

-- | Functions             | Description                                                                              |
-- | ------------------    | ------------------                                                                       |
-- | `builtin.find_files`  | Lists files in your current working directory, respects .gitignore                       |
-- | `builtin.git_files`   | Fuzzy search through the output of `git ls-files` command, respects .gitignore           |
-- | `builtin.grep_string` | Searches for the string under your cursor or selection in your current working directory |
-- | `builtin.live_grep`   | Search for a string in your current working directory and get results live as you type.  |

-- ### Vim Pickers

-- | Functions                           | Description                                                                                  |
-- | ------------------                  | -----                                                                                        |
-- | `builtin.buffers`                   | Lists open buffers in current neovim instance                                                |
-- | `builtin.oldfiles`                  | Lists previously open files                                                                  |
-- | `builtin.commands`                  | Lists available plugin/user commands and runs them on `<cr>`                                 |
-- | `builtin.tags`                      | Lists tags in current directory with tag location file preview (required to run `ctags -R`)  |
-- | `builtin.command_history`           | Lists commands that were executed recently, and reruns them on `<cr>`                        |
-- | `builtin.search_history`            | Lists searches that were executed recently, and reruns them on `<cr>`                        |
-- | `builtin.help_tags`                 | Lists available help tags and opens a new window with the relevant help info on `<cr>`       |
-- | `builtin.man_pages`                 | Lists manpage entries, opens them in a help window on `<cr>`                                 |
-- | `builtin.marks`                     | Lists vim marks and their value                                                              |
-- | `builtin.colorscheme`               | Lists available colorschemes and applies them on `<cr>`                                      |
-- | `builtin.quickfix`                  | Lists items in the quickfix list                                                             |
-- | `builtin.quickfixhistory`           | Lists all quickfix lists in your history                                                     |
-- | `builtin.loclist`                   | Lists items from the current window's location list                                          |
-- | `builtin.jumplist`                  | Lists Jump List entries                                                                      |
-- | `builtin.vim_options`               | Lists vim options, allows you to edit the current value on `<cr>`                            |
-- | `builtin.registers`                 | Lists vim registers, pastes the contents of the register on `<cr>`                           |
-- | `builtin.autocommands`              | Lists vim autocommands and goes to their declaration on `<cr>`                               |
-- | `builtin.keymaps`                   | Lists normal mode keymappings                                                                |
-- | `builtin.filetypes`                 | Lists all available filetypes                                                                |
-- | `builtin.highlights`                | Lists all available highlights                                                               |
-- | `builtin.current_buffer_fuzzy_find` | Live fuzzy search inside of the currently open buffer                                        |
-- | `builtin.current_buffer_tags`       | Lists all of the tags for the currently open buffer, with a preview                          |
-- | `builtin.resume`                    | Lists the results incl. multi-selections of the previous picker                              |
-- | `builtin.pickers`                   | Lists the previous pickers incl. multi-selections (see `:h telescope.defaults.cache_picker`) |

-- ### Neovim LSP Pickers

-- | Functions                               | Description                                                                                |
-- | -------                                 | ---------                                                                                  |
-- | `builtin.lsp_references`                | Lists LSP references for word under the cursor                                             |
-- | `builtin.lsp_incoming_calls`            | Lists LSP incoming calls for word under the cursor                                         |
-- | `builtin.lsp_outgoing_calls`            | Lists LSP outgoing calls for word under the cursor                                         |
-- | `builtin.lsp_document_symbols`          | Lists LSP document symbols in the current buffer                                           |
-- | `builtin.lsp_workspace_symbols`         | Lists LSP document symbols in the current workspace                                        |
-- | `builtin.lsp_dynamic_workspace_symbols` | Dynamically Lists LSP for all workspace symbols                                            |
-- | `builtin.diagnostics`                   | Lists Diagnostics for all open buffers or a specific buffer, `bufnr=0` for current buffer. |
-- | `builtin.lsp_implementations`           | Goto the implementation of the word under the cursor if there's only one.                  |
-- | `builtin.lsp_definitions`               | Goto the definition of the word under the cursor.                                          |
-- | `builtin.lsp_type_definitions`          | Goto the definition of the type of the word under the cursor.                              |


-- ### Git Pickers

-- | Functions              | Description                                                                                                |
-- | ------------------     | -------------                                                                                              |
-- | `builtin.git_commits`  | Lists git commits with diff preview, checkout action `<cr>`, reset action for `<C-r>m`, `<C-r>s`, `<C-r>h` |
-- | `builtin.git_bcommits` | Lists buffer's git commits with diff preview and checks them out on `<cr>`                                 |
-- | `builtin.git_branches` | Lists all branches with log preview, checkout action `<cr>`, track action `<C-t>` and rebase action`<C-r>` |
-- | `builtin.git_status`   | Lists current changes per file with diff preview and add action. (Multi-selection still WIP)               |
-- | `builtin.git_stash`    | Lists stash items in current repository with ability to apply them on `<cr>`                               |

-- ### Treesitter Picker

-- | Functions            | Description                                       |
-- | ------------------   | -------------                                     |
-- | `builtin.treesitter` | Lists Function names, variables, from Treesitter! |

-- ### Lists Picker

-- | Functions          | Description                                                                    |
-- | ------------------ | ----------------                                                               |
-- | `builtin.planets`  | Use the telescope...                                                           |
-- | `builtin.builtin`  | Lists Built-in pickers and run them on `<cr>`.                                 |
-- | `builtin.reloader` | Lists Lua modules and reload them on `<cr>`.                                   |
-- | `builtin.symbols`  | Lists symbols inside a file `data/telescope-sources/*.json` found in your rtp. |

-- ## Previewers

-- | Previewers                          | Description                                               |
-- | -----------------                   | --                                                        |
-- | `previewers.vim_buffer_cat.new`     | Default previewer for files. Uses vim buffers             |
-- | `previewers.vim_buffer_vimgrep.new` | Default previewer for grep and similar. Uses vim buffers  |
-- | `previewers.vim_buffer_qflist.new`  | Default previewer for qflist. Uses vim buffers            |
-- | `previewers.cat.new`                | Terminal previewer for files. Uses `cat`/`bat`            |
-- | `previewers.vimgrep.new`            | Terminal previewer for grep and similar. Uses `cat`/`bat` |
-- | `previewers.qflist.new`             | Terminal previewer for qflist. Uses `cat`/`bat`           |
