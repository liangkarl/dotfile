return {
  'marko-cerovac/material.nvim',
  init = function()
    require('material').setup({
      plugins = {
        "dap",
        "gitsigns",
        "neogit",
        "nvim-cmp",
        "nvim-tree",
        "nvim-web-devicons",
        "which-key",
        "trouble",
        "mini",
        -- "telescope",
      },
      -- Fix mini.cursor color could not be changed as the async loading
      -- makes setup sequence unstable
      async_loading = false,
    })
    vim.g.material_style = 'darker'
    vim.cmd.colorscheme('material-darker')
  end,
},
{
  'sainnhe/sonokai',
  config = function()
    vim.g.sonokai_style = 'shusia'
    vim.g.sonokai_enable_italic = 1
    vim.g.sonokai_disable_italic_comment = 1
  end
},
{
  'sainnhe/gruvbox-material',
  config = function()
    vim.cmd('set background=dark')
    vim.g.gruvbox_material_background = 'soft'
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_disable_italic_comment = 1
    vim.g.gruvbox_material_better_performance = 1
  end
},
{
  'navarasu/onedark.nvim',
  config = function()
    vim.g.onedark_style = 'warmer'
  end
}
