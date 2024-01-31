-- Plugin: vim-matchup
return { -- enhance '%' function, like if-endif
  'andymass/vim-matchup',
  dependency = {
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    -- disable nvim builtin plugin matchit
    vim.g.loaded_matchit = 1

    vim.cmd([[
      let g:matchup_matchparen_offscreen = {'method': 'status_manual'}
    ]])

    local ok, treesitter = pcall(require, 'nvim-treesitter.configs')

    if not ok then
      return
    end

    treesitter.setup {
      matchup = {
        enable = true,              -- mandatory, false will disable the whole extension
      },
    }
  end
}
