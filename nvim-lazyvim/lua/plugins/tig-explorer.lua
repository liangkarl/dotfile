-- Plugin: tig-explorer.vim
-- https://github.com/iberianpig/tig-explorer.vim

-- As the offical guide said, tig-explorer depends on the plugin, bclose,
-- which is an really old plugin.
-- command! -bang -nargs=1 -complete=buffer Bclose bdelete! <f-args>

local keymaps = require("config.keymaps")

return { --   " git blame whole file
    'liangkarl/tig-explorer.vim',
    cmd = { "Tig", "TigOpenCurrentFile", "TigOpenProjectRootDir", "TigBlame", "TigStatus", "TigGrep", "TigGrepResume", "TigOpenFileWithCommit" },
    keys = keymaps.tig_keys,
    init = function()
        local command = vim.api.nvim_create_user_command
        command("Bclose", function ()
                require("mini.bufremove").delete(0)
            end,
            { bang = true })
    end
}
