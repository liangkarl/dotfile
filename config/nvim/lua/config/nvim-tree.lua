-- Plugin: nvim-tree
-- https://github.com/kyazdani42/nvim-tree.lua
-- |------+------------------------------|
-- | key  | explain                      |
-- |------+------------------------------|
-- | a    | add file, end of '/' for dir |
-- | d    | delete file/dir              |
-- | r    | rename file/dir              |
-- | H    | Toggle hidden                |
-- | o    | toggle expand/collapse       |
-- | <cr> | enter cursored folder        |
-- | R    | refresh tree list            |
-- | q    | quit explore                 |
-- |------+------------------------------|

local function opts(desc)
  return {
    desc = 'nvim-tree: ' .. desc,
    buffer = bufnr,
    noremap = true,
    silent = true,
    nowait = true
  }
end

local HEIGHT_RATIO = 0.8 -- You can change this
local WIDTH_RATIO = 0.5  -- You can change this too
local api = require("nvim-tree.api")

local M = {}

function M.on_attach(bufnr)
  -- FIXME: the help window would be placed in left side
  vim.keymap.set('n', 'h', api.tree.toggle_help, opts('help'))
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('help'))
  vim.keymap.set('n', '<C-c>', api.tree.close, opts('close'))

  api.config.mappings.default_on_attach(bufnr)
end

require('nvim-tree').setup {
  on_attach = M.on_attach;
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  view = {
    relativenumber = true,
    float = {
      enable = true,
      open_win_config = function()
        local screen_w = vim.opt.columns:get()
        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        local window_w = screen_w * WIDTH_RATIO
        local window_h = screen_h * HEIGHT_RATIO
        local window_w_int = math.floor(window_w)
        local window_h_int = math.floor(window_h)
        local center_x = (screen_w - window_w) / 2
        local center_y = ((vim.opt.lines:get() - window_h) / 2)
                         - vim.opt.cmdheight:get()
        return {
          border = "rounded",
          relative = "editor",
          row = center_y,
          col = center_x,
          width = window_w_int,
          height = window_h_int,
        }
        end,
    },
    width = function()
      return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
    end,
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
    special_files = {
      "Cargo.toml",
      "Makefile",
      "README.md",
      "readme.md",
      "Android.mk",
      "Android.bp",
      "Kconfig",
    },
  },
  actions = {
    use_system_clipboard = true,
    change_dir = {
      enable = true,
      global = true,
      restrict_above_cwd = false,
    },
    open_file = {
      quit_on_open = true,
    },
    remove_file = {
      close_window = false,
    },
  },
  update_cwd = true,
  update_focused_file = {
    enable      = true,
    update_cwd  = true,
    ignore_list = {}
  },
  filters = {
    dotfiles = true,
    custom = {}
  },
}

-- To function NvimTree auto-closed, here we may have side effect.
-- https://github.com/kyazdani42/nvim-tree.lua/issues/1368
vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil then
      vim.cmd "NvimTreeClose"
      vim.cmd "qa!"
    end
  end
})

vim.keymap.set('n', '<leader>ft', ':NvimTreeToggle<cr>')
