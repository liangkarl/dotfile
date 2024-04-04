local M = {}
local vim = vim
local fn = vim.fn
local m = require("helpers.utils")

-- Show information about the current file
M.show_file_info = function()
  vim.notify(string.format('File: %s\nCWD:  %s',
      vim.fn.expand('%:p'), vim.fn.getcwd()))
end

-- Change the current working directory to the file's directory
M.change_cwd = function()
  vim.cmd('lcd %:p:h')
  vim.notify('Set CWD to ' .. vim.fn.getcwd())
end

-- Reload the Neovim configuration
M.reload_settings = function()
  vim.cmd('source $MYVIMRC')
  vim.notify('Reload: ' .. vim.env.MYVIMRC)
end

-- Update the Neovim configuration
M.edit_settings = function()
  vim.cmd('edit $MYVIMRC')
  m.autocmd('BufDelete', vim.env.MYVIMRC, function()
    vim.cmd('source ' .. vim.env.MYVIMRC)
    vim.notify('Reload: ' .. vim.env.MYVIMRC)
  end, {
    group = m.augroup('NvimSetup')
  })
end

-- Save buffer content if modifiable is 'on'
M.close_buf = function()
  -- Get listed buffer
  local listed_buffers = fn.filter(fn.getbufinfo({buflisted = 1}), 'v:val.listed == 1')

  if #listed_buffers <= 1 then
    vim.cmd('quit!')
  else
    -- Usually, the modifiable buffer would be the main window and
    -- the nomodifiable buffer would be the side window
    if vim.bo.modifiable then
      vim.cmd('lua MiniBufremove.delete(0)')
    else
      vim.cmd('silent! bdelete!')
    end
  end
end

return { -- Display cheat sheet of vim shortcut
  'folke/which-key.nvim',
  dependencies = {
    -- FIXME:
    -- Check dependencies
    -- For now, we use vim command to avoid dependency problems
  },
  config = function()
    local wk = require("which-key")
    local lsp = vim.lsp.buf
    local gid

    -- NOTE:
    -- '' in map mode means normal, visual and select modes

    -------------------------------
    -- Overide original keybinds --
    -------------------------------

    gid = m.augroup("KeybindProfile")

    m.autocmd({ "BufAdd", "OptionSet" }, "*", function()
      if vim.o.diff then
        m.noremap('n', 'Q', '<cmd>qall<cr>', "Quit all")
        m.noremap('n', '<leader>q', '<cmd>diffoff | only<cr>', "Back to Normal edit mode")
      end

      if not vim.o.modifiable then
        -- Using :quit instead of :close is because :quit could exit nvim
        -- once the current buffer is the last buffer
        m.noremap('n', 'q', '<cmd>quit<cr>', "Close buffer", { buffer = true })
      end
    end, {
      desc = "Set different keybinds according to the options",
      group = gid
    })

    -- Available list:
    -- '(', ')', ';', ',', Z, H, L, t, T, F, M, sX

    --  <C-c>: leave Insert Mode and return to Normal Mode.
    --    The difference between <C-c> and <Esc> is as below:
    --    1. Would not check abbreviations
    --    2. Would not trigger `InsertLeave` event of autocommand.
    m.noremap('i', '<C-c>', '<Esc>', "<ESC>")
    m.noremap('v', 'p', 'P', "Paste without yanking the deleted text")

    -- Retain the visual selection after indent lines
    m.noremap('v', '>', '>gv', 'Indent line(s) more')
    m.noremap('v', '<', '<gv', 'Indent line(s) less')

    -- Move visual block
    m.noremap('v', 'J', ":m '>+1<cr>gv=gv", "Move visual block up")
    m.noremap('v', 'K', ":m '<-2<cr>gv=gv", "Move visual block down")

    -- The highest keybind priority
    -- m.noremap('n', 'H', '<C-w>W', "Switch to preview window")
    m.noremap('n', '\\', '<C-w>w', "Switch to next window")
    m.noremap('n', '<S-Tab>', '<cmd>BufferLineCyclePrev<cr>', "Switch to previous buffer")
    m.noremap('n', '<Tab>', '<cmd>BufferLineCycleNext<cr>', "Switch to next buffer")
    m.noremap({ 't', 'i', 'n' }, '<C-\\>', '<cmd>1ToggleTerm direction=tab<cr>', "ToggleTern in Tab")

    m.noremap('',  'f', '<cmd>HopChar1CurrentLineAC<cr>')
    m.noremap('',  'F', '<cmd>HopChar1CurrentLineBC<cr>')

    -------------------
    -- Direct Keymap --
    -------------------
    m.noremap('n', '<leader>\\', '<C-w>w', "Switch to next window")
    m.noremap('n', '<leader><S-Tab>', '<cmd>BufferLineCyclePrev<cr>', "Switch to previous buffer")
    m.noremap('n', '<leader><Tab>', '<cmd>BufferLineCycleNext<cr>', "Switch to next buffer")
    m.noremap('',  '<leader>0', '^', "Go to the first character of line")
    m.noremap('',  '<leader>9', '$', "Go to the end of line")
    m.noremap('n', '<leader>?', '<cmd>Telescope keymaps<cr>', "Open keymaps")
    m.noremap('n', '<leader>h', '<cmd>Telescope help_tags<cr>', "Show help manuals like :help")
    -- Search
    m.noremap('v', '<leader>/', '<Esc>/\\%V', "Search within selected block")
    -- Coding
    m.noremap('n', '<leader>!', '<cmd>ToggleAlternate<cr>', "Invert boolean value")
    -- There are two different clipboards for Linux and only one for Win
    -- *: clipboard for copy-on-select
    -- +: clipboard for <C-c> and <C-v>
    m.noremap('',  '<leader>y', '"+y', "Copy to Clipboard")
    m.noremap('',  '<leader>p', '"+p', "Paste from Clipboard")
    m.noremap('',  '<leader>Y', '"*y', "Copy to 'copy-on-select' Clipboard")
    m.noremap('',  '<leader>P', '"*p', "Paste from 'copy-on-select' Clipboard")
    m.noremap('',  '<leader>=', function() lsp.format({ async = true }) end, "Format code (LSP)")
    m.noremap('n', '<leader>b', '<cmd>Telescope buffers<cr>', "Switch opened buffers")
    m.noremap('',  '<leader><Tab>', '<cmd>b#<cr>', "Switch to last buffer")
    m.noremap('n', '<leader>S', '<cmd>AerialToggle<cr>', 'Symbol Manager')
    m.noremap('n', '<leader>F', '<cmd>lua MiniFiles.open()<cr>', 'File Explorer')
    m.noremap('n', '<leader>d', M.close_buf, "Close current buffer")
    m.noremap('',  '<leader>j', '<cmd>HopChar1<cr>')
    m.noremap('',  '<leader>J', '<cmd>HopPattern<cr>')
    m.noremap('',  '<leader>l', '<cmd>HopWord<cr>')
    m.noremap('',  '<leader>k', '<cmd>HopVertical<cr>')

    -------------------
    -- Folded Keymap --
    -------------------
    wk.setup()
    wk.register({
      ["<leader>"] = {
        ['f']  = { name = "File" },
        ['/']  = { name = "Search / Edit" },
        [';']  = { name = "Coding" },
        ['\''] = { name = "Debug / Compile" },
        ['w']  = { name = "Window / Plugin" },
        ['s']  = { name = "Setup / Status" },
      }
    })

    -- File (Open/Close/Save)
    -- m.noremap('n', '<leader>', '', "Open file (Current file path)")
    m.noremap('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', "Open recently closed files")
    m.noremap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', "Open files")
    m.noremap('n', '<leader>fw', '<cmd>w<cr>', "Save")
    -- m.noremap('n', '<leader>fm', '<cmd>Bdelete menu<cr>', "Show delete menu")
    -- m.noremap('n', '<leader>fD', '<cmd>Bdelete select<cr>', "Select")
    m.noremap('n', '<leader>fg', '<cmd>TigOpenCurrentFile<cr>', "Git log with current file")
    m.noremap('n', '<leader>fb', '<cmd>TigBlame<cr>', "Blame file")

    -- Search
    m.noremap('n', '<leader>/', '<cmd>Telescope live_grep<cr>', "Grep under CWD (Telescope)")
    m.noremap('n', '<leader>/w', '<cmd>Telescope grep_string<cr>', "Search <cword> under CWD (Telescope)")
    m.noremap('n', '<leader>/b', '<cmd>Telescope current_buffer_fuzzy_find<cr>', "Search in current buffer (Telescope)")
    -- https://stackoverflow.com/questions/40867576/how-to-use-vimgrep-to-grep-work-thats-high-lighted-by-vim
    m.noremap('n', '<leader>/s', function()
      vim.cmd("exe 'vimgrep' expand('<cword>') '%'")
      vim.cmd("copen")
    end, "Search current cursor string (Quickfix)")

    -- Coding
    m.noremap("n", "<leader>;r", '<cmd>Glance references<cr>', "Code Reference (Glance)")
    m.noremap('n', '<leader>;d', '<cmd>Glance definitions<cr>', "Definition (Glance)")
    m.noremap('n', '<leader>;D', '<cmd>Glance type_definitions<cr>', "Type Definition (Glance)")
    m.noremap('n', '<leader>;p', '<cmd>Glance implementations<cr>', "Implementations (Glance)")
    m.noremap('n', '<leader>;n', lsp.rename, "Rename (LSP)")
    m.noremap('',  '<leader>;c', lsp.code_action, "Show code action menu (LSP)")
    m.noremap('n', '<leader>;v', lsp.hover, "Show info (LSP)")
    m.noremap('n', '<leader>;h', lsp.signature_help, "Show signatures (LSP)")
    m.noremap("n", "<leader>;w", '<cmd>TroubleToggle workspace_diagnostics<cr>', "Diagnostic Workspace (Trouble)")
    m.noremap("n", "<leader>;f", '<cmd>TroubleToggle document_diagnostics<cr>', "Diagnostic Document (Trouble)")

    -- Compile/ Debug
    m.noremap('n', '<leader>\'b', "<cmd>DapToggleBreakpoint<cr>")
    m.noremap('n', '<leader>\'c', "<cmd>DapContinue<cr>")
    m.noremap('n', '<leader>\'s', "<cmd>DapStepOver<cr>")
    m.noremap('n', '<leader>\'i', "<cmd>DapStepInto<cr>")
    m.noremap('n', '<leader>\'o', "<cmd>DapStepOut<cr>")
    m.noremap('n', '<leader>\'t', "<cmd>DapToggleRepl<cr>")

    -- Window
    m.noremap('n', '<leader>wo', '<cmd>only<cr>', "Close all other windows")
    m.noremap('n', '<leader>wt', '<cmd>Telescope builtin include_extensions=true<cr>', "Telescope: Main Menu")
    m.noremap('n', '<leader>wg', '<cmd>TigOpenProjectRootDir<cr>', "Tig: Project Root Dir")
    m.noremap("n", "<leader>wq", '<cmd>TroubleToggle quickfix<cr>', "Trouble: Toggle Quickfix")
    m.noremap("n", "<leader>wQ", '<cmd>TroubleToggle loclist<cr>', "Trouble: Toggle Quickfix")
    m.noremap('n', '<leader>wr', '<cmd>Telescope registers<cr>', "Open registers")
    -- m.noremap('n', '<leader>sm', '<cmd>Outline<cr>', 'Toggle Outline Symbol Manager')
    -- m.noremap('n', '<leader>si', '<cmd>OutlineStatus<cr>', 'Get Outline Symbol Manager info')

    -- Setting/ Status
    m.noremap('n', '<leader>sa', lsp.add_workspace_folder, "Add LSP workspace")
    m.noremap('n', '<leader>sr', lsp.remove_workspace_folder, "Remove LSP workspace")
    m.noremap('n', '<leader>sw', function()
      -- TODO: Add to quickfix list
      print(vim.inspect(lsp.list_workspace_folders()))
    end, "Show LSP workspace")
    m.noremap('n', '<leader>st', '<cmd>Telescope filetypes<cr>', "Change filetypes")
    m.noremap('n', '<leader>sl', '<cmd>Mason<cr>', "Mason: Main Menu")
    m.noremap('n', '<leader>sp', '<cmd>Lazy<cr>', "Lazy: Main Menu")
    m.noremap('n', '<leader>si', '<cmd>LspInfo<cr>', "LSP Server Info (LspInfo)")
    m.noremap('n', '<leader>sm', '<cmd>AerialInfo<cr>', 'Symbol Manager Info (AerialInfo)')
    m.noremap('n', '<leader>sg', '<cmd>GuessIndent<cr>', 'Set up indent (GuessIndent)')
    m.noremap('n', '<leader>sc', M.change_cwd, "Set CWD to current buffer")
    m.noremap('n', '<leader>sf', M.show_file_info, "Show File and CWD info")
    m.noremap('n', '<leader>sr', M.reload_settings, "Reload init.lua")
    m.noremap('n', '<leader>s,', M.edit_settings, "Edit runtime init.lua")

    -- Replace
    m.noremap('n', '<leader>sd', '<cmd>lua MiniTrailspace.trim()<cr>', 'Remove trailing spaces')

  end
}
