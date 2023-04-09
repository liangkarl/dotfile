-- Plugin: nvim-tree
-- https://github.com/kyazdani42/nvim-tree.lua
require('nvim-tree').setup {
  hijack_directories = {
    enable = true,
    auto_open = true,
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

vim.g.nvim_tree_quit_on_open = 1
vim.g.nvim_tree_icon_padding = ' '

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
