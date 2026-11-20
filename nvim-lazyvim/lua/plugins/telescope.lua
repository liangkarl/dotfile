-- Plugin: telescope.nvim
-- https://github.com/nvim-telescope/telescope.nvim

local keymaps = require("config.keymaps")

return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'zane-/cder.nvim',
      -- The legacy scriptnames extension is unavailable from its old Git URL.
      -- Neovim's :scriptnames still lists sourced scripts.
      'debugloop/telescope-undo.nvim',
      -- The legacy Telescope LuaSnip extension requires LuaSnip.
      'fdschmidt93/telescope-egrepify.nvim',
    },
    opts = function(_, opts)
      local themes = require("telescope.themes")
      local maps = keymaps.telescope_mappings()
      local drop_layout = themes.get_dropdown({
        layout_config = {
          width = 0.6,
          height = 0.5,
        },
        path_display = {},
      })
      local cursor_layout = themes.get_cursor({
        layout_config = {
          width = 0.6,
          height = 0.5,
        },
      })

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        layout_strategy = "center",
        layout_config = { center = { width = 0.6, height = 0.5 } },
        preview = { hide_on_startup = true },
        mappings = maps.preview,
      })

      local legacy = {
        defaults = {
          layout_strategy = 'center',
          layout_config = {
            center = {
              preview_cutoff = 15,
              width = 0.6,
              height = 0.5,
            },
            vertical = {
              prompt_position = "top",
              preview_cutoff = 15,
              width = 0.6,
              height = 0.5,
            },
            bottom_pane = {
              prompt_position = "bottom",
              height = 0.4,
              preview_width = 0.7,
            },
            -- TODO: customized layout
            -- bottom_vertical = {
            --   prompt_position = "bottom",
            --   preview_cutoff = 15,
            --   height = 0.36,
            --   preview_width = 0.7,
            --   width = 1,
            -- },
          },
          preview = {
            hide_on_startup = true,
          },
          dynamic_preview_title = true,
          -- If the path is too long to show
          -- path_display = {
          --   shorten = {
          --     len = 2,
          --     exclude = { -1 }
          --   },
          -- },
          mappings = maps.defaults,
        },
        pickers = {
          keymaps = drop_layout,
          help_tags = drop_layout,
          man_pages = drop_layout,
          oldfiles = drop_layout,
          find_files = drop_layout,
          grep_string = { layout_strategy = 'bottom_pane' },
          lsp_definitions = { layout_strategy = 'bottom_pane' },
          lsp_implementations = { layout_strategy = 'bottom_pane' },
          lsp_type_definitions = { layout_strategy = 'bottom_pane' },
          lsp_references = { layout_strategy = 'bottom_pane' },
          lsp_outgoing_calls = cursor_layout,
          lsp_incoming_calls = cursor_layout,
          buffers = {
            mappings = maps.buffers,
          }
        },
        extensions = {
          cder = {
            previewer_command = 'tree -L 1 -F --dirsfirst -h',
            pager_command = 'cat',
            dir_command = { 'fd', '-I', '--type=d', '.', function()
              return vim.fn.getcwd()
            end },
          },
          fzf = {
            fuzzy = false,                  -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          },
          egrepify = {
            layout_strategy = "bottom_pane",
            -- intersect tokens in prompt ala "str1.*str2" that ONLY matches
            -- if str1 and str2 are consecutively in line with anything in between (wildcard)
            AND = true,                   -- default
            permutations = false,         -- opt-in to imply AND & match all permutations of prompt tokens
            lnum = true,                  -- default, not required
            lnum_hl = "EgrepifyLnum",     -- default, not required, links to `Constant`
            col = false,                  -- default, not required
            col_hl = "EgrepifyCol",       -- default, not required, links to `Constant`
            title = true,                 -- default, not required, show filename as title rather than inline
            filename_hl = "EgrepifyFile", -- default, not required, links to `Title`
            results_ts_hl = true,         -- set to false if you experience latency issues!
            -- suffix = long line, see screenshot
            -- EXAMPLE ON HOW TO ADD PREFIX!
            prefixes = {
              -- ADDED ! to invert matches
              -- example prompt: ! sorter
              -- matches all lines that do not comprise sorter
              -- rg --invert-match -- sorter
              ["!"] = {
                flag = "invert-match",
              },
              -- HOW TO OPT OUT OF PREFIX
              -- ^ is not a default prefix and safe example
              -- ["^"] = false
            },
            -- default mappings
            mappings = maps.egrepify,
          },
        }
      }
      return vim.tbl_deep_extend("keep", opts, legacy)
    end,
    keys = keymaps.telescope_keys,
  },
}
