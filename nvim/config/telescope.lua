-- Plugin: telescope.nvim
-- https://github.com/nvim-telescope/telescope.nvim

local m = require('helpers.utils')
local opts = { noremap=true, silent=true }

-- WA for multi-selections
-- https://github.com/nvim-telescope/telescope.nvim/issues/1048
local select_one_or_multi = function(prompt_bufnr)
  local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not vim.tbl_isempty(multi) then
    require('telescope.actions').close(prompt_bufnr)
    for _, j in pairs(multi) do
      if j.path ~= nil then
        vim.cmd(string.format('%s %s', 'edit', j.path))
      end
    end
  else
    require('telescope.actions').select_default(prompt_bufnr)
  end
end


return {
  { -- provides superior project management
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
        -- Manual mode doesn't automatically change your root directory, so you have
        -- the option to manually do so using `:ProjectRoot` command.
        manual_mode = false,

        -- Methods of detecting the root directory. **"lsp"** uses the native neovim
        -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
        -- order matters: if one is not detected, the other is used as fallback. You
        -- can also delete or rearangne the detection methods.
        detection_methods = { "pattern", "lsp" },

        -- All the patterns used to detect root dir, when **"pattern"** is in
        -- detection_methods
        patterns = { ".project", ".git", },

        -- What scope to change the directory, valid options are
        -- * global (default)
        -- * tab
        -- * win
        scope_chdir = 'win',

        -- Path where project.nvim will store the project history for use in
        -- telescope
        datapath = vim.fn.stdpath("data"),
      }
    end,
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'zane-/cder.nvim',
      'LinArcX/telescope-scriptnames.nvim',
      "SalOrak/whaler",
      'debugloop/telescope-undo.nvim',
      "benfowler/telescope-luasnip.nvim"
    },
    config = function()
      local telescope = require('telescope')

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
          mappings = {
            i = {
              ['<CR>'] = select_one_or_multi,
            }
          }
        },
        extensions = {
          cder = {
            previewer_command = 'ls -v --group-directories-first -N --color=auto',
            pager_command = 'cat',
          }
        }
      })

      -- To get fzf loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      telescope.load_extension('fzf')
      telescope.load_extension('cder')
      telescope.load_extension('projects')
      telescope.load_extension('scriptnames')
      telescope.load_extension('undo')
      telescope.load_extension('whaler')
      telescope.load_extension('luasnip')

      -- Find files using Telescope command-line sugar.
      m.noremap('n', '<leader>fs', '<cmd>Telescope builtin include_extensions=true<cr>', "Telescope main menu")
      m.noremap('n', '<leader>ff', '<cmd>Telescope oldfiles<cr>', "Open recently closed files")
      m.noremap('n', '<leader>fF', '<cmd>Telescope find_files<cr>', "Open files")
      m.noremap('n', '<leader>fg', '<cmd>Telescope grep_string<cr>', "Grep current curosr word")
      m.noremap('n', '<leader>fG', '<cmd>Telescope live_grep<cr>', "Grep assigned words")
      m.noremap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', "Pick up opened buffers")
      m.noremap('n', '<leader>fr', '<cmd>Telescope registers<cr>', "Open registers")
      m.noremap('n', '<leader>f?', '<cmd>Telescope keymaps<cr>', "Open keymaps")
      m.noremap('n', '<leader>fe', '<cmd>Telescope filetypes<cr>', "Change filetypes")
      m.noremap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', "Show help manuals like :help")
    end,
  },
}

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
