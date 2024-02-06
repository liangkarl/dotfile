return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local m = require('helpers.utils')
    local t = require('trouble')
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    -- Lua
    -- m.noremap("n", "<leader>xx", function() t.toggle() end)
    m.noremap("n", "<leader>lw", function() t.toggle("workspace_diagnostics") end, "LSP: Diagnostic Workspace")
    m.noremap("n", "<leader>lf", function() t.toggle("document_diagnostics") end, "LSP: Diagnostic Document")

    -- LSP
    -- Only covered parts of vim.diagnostics API. The rest of them are in `nvim-lspconfig`
    -- https://neovim.io/doc/user/lsp.html#lsp-buf
    m.noremap("n", "<leader>lr", function() t.toggle("lsp_references") end, "LSP: List referenced codes")
    m.noremap('n', '<leader>ld', function() t.toggle('lsp_definitions') end, "LSP: Jump to definition")
    m.noremap('n', '<leader>lt', function() t.toggle('lsp_type_definitions') end, "LSP: Jump to type definition")
    m.noremap('n', '<leader>lp', function() t.toggle('lsp_implementations') end, "LSP: Jump to implementations")

    -- Quickfix
    m.noremap("n", "<leader>tq", function() t.toggle("quickfix") end, "Trouble: Toggle Quickfix")

    -- Loclist
    m.noremap("n", "<leader>tl", function() t.toggle("loclist") end, "Trouble: Toggle Loclist")

    -- https://stackoverflow.com/questions/40867576/how-to-use-vimgrep-to-grep-work-thats-high-lighted-by-vim
    m.noremap('n', '<leader>fW', function()
      vim.cmd(string.format("exe 'vimgrep' '/%s/j %%'", vim.fn.input('search pattern: ')))
      t.toggle('quickfix')
    end, "Search string (Quickfix)")

    m.noremap('n', '<leader>fw', function ()
      vim.cmd("exe 'vimgrep' expand('<cword>') '%'")
      t.toggle('quickfix')
    end, "Search string under cursor (Quickfix)")
  end
}
