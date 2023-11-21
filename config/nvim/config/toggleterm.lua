require("toggleterm").setup({
    -- size can be a number or function which is passed the current terminal
  size = function(term)
    if term.direction == "horizontal" then
      return math.floor(vim.o.lines * 0.25)
    elseif term.direction == "vertical" then
      return math.floor(vim.o.columns * 0.7)
    end
  end,
  direction = 'horizontal',
  auto_scroll = true,
  float_opts = {
    -- The border key is *almost* the same as 'nvim_open_win'
    -- see :h nvim_open_win for details on borders however
    -- the 'curved' border is a custom border type
    -- not natively supported but implemented in this plugin.
    border = 'curved',
    width = function (_)
      return math.floor(vim.o.columns * 0.7)
    end,
    height = function (_)
      return math.floor(vim.o.lines * 0.7)
    end,
    winblend = 3,
    zindex = 1,
    -- TODO: alias vim as we want to open outside the toggleterm
    -- on_open = function (term)
    --   vim.cmd([[TermExec cmd='alias vim="nvr -l"']])
    -- end
  },

  winbar = {
    enabled = false,
    name_formatter = function(term) --  term: Terminal
      return term.name
    end
  },
  hide_numbers = true, -- hide the number column in toggleterm buffers
  autochdir = false, -- when neovim changes it current directory the terminal
                     -- will change it's own when next it's opened
  shell = vim.o.shell,
  open_mapping = [[<C-\>]],
})

vim.cmd('nnoremap <leader>ts <Cmd>ToggleTermSendCurrentLine<cr>')
vim.cmd('vnoremap <leader>ts <Cmd>ToggleTermSendVisualSelection<cr>')

vim.cmd('nnoremap <leader>\\ <Cmd>ToggleTerm direction=tab name=tab-term<cr>')
vim.cmd('autocmd FileType toggleterm tnoremap <buffer> <Esc> <C-\\><C-n>')
vim.cmd('autocmd FileType toggleterm tnoremap <buffer> <C-x> <C-\\><C-n>')
vim.cmd('autocmd FileType toggleterm nnoremap <buffer> <Esc> <Cmd>ToggleTerm<cr>')
vim.cmd('autocmd FileType toggleterm nnoremap <buffer> q <Cmd>ToggleTerm<cr>')
