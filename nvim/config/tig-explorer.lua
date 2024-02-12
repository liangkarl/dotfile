-- Plugin: tig-explorer.vim
-- https://github.com/iberianpig/tig-explorer.vim

-- As the offical guide said, tig-explorer depends on the plugin, bclose,
-- which is an really old plugin.
-- command! -bang -nargs=1 -complete=buffer Bclose bdelete! <f-args>

local command = vim.api.nvim_create_user_command

command("Bclose", function ()
      vim.cmd("lua MiniBufremove.delete(0)")
    end, { bang = true })
