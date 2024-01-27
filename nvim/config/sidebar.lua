return {
  'liangkarl/sidebar.nvim',
  config = function()
    local sidebar = require("sidebar-nvim")

    sidebar.setup({
      sections = {
        'buffers',
        'files',
      },
      section_separator = ""
    })

    vim.cmd([[
      nnoremap <silent><leader>. :lua require('sidebar-nvim').toggle()<cr>
    ]])
  end
}
