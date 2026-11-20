return {
  'kkoomen/vim-doge',
  build = function ()
    vim.cmd('call doge#install()')
  end
}
