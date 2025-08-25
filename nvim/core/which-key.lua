local M = {}
local vim = vim
local fn = vim.fn
local m = require("core.utils")

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

local function config()
  local wk = require("which-key")
  local lsp = vim.lsp.buf
  local gid

  local exe_loop = function(list)
    local ok

    for _,t in ipairs(list) do
      ok = pcall(require, t.id)
      if ok == true then
        vim.cmd(t.action)
        return
      end
    end

    print("no matched function for the key")
  end

  local tel_bltn = require("telescope.builtin")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  function grep_string_open(prompt_bufnr, map)
    actions.select_default:replace(function()
      -- 先取得選擇的 entry
      local entry = action_state.get_selected_entry()
      local filename = vim.fn.fnamemodify(entry.path or entry.filename, ":p")
      local lnum = entry.lnum or 1

      -- 在離開 Telescope 前，push 當前位置到 jumps
      vim.cmd("normal! m'")

      -- 執行原本的 select_default 行為
      actions.close(prompt_bufnr)

      -- 最後打開檔案並移動到正確行
      vim.cmd(string.format("edit +%d %s", lnum, filename))
    end)
    return true
  end
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

  -- XXX: WA for 'E335: Menu not defined for Insert mode'
  -- https://github.com/neovim/neovim/issues/19473
  m.noremap('v', '<RightMouse>', '<C-\\><C-g>gv<cmd>:popup! PopUp<cr>', "FIX E335 for popup issue")

  -- Available list:
  -- '(', ')', ';', ',', Z, H, L, t, T, F, M, sX

  --  <C-c>: leave Insert Mode and return to Normal Mode.
  --    The difference between <C-c> and <Esc> is as below:
  --    1. Would not check abbreviations
  --    2. Would not trigger `InsertLeave` event of autocommand.
  m.noremap('i', '<C-c>', '<Esc>', "<ESC>")
  m.noremap('i', '<C-s>', '<C-o>', "<C-o>")
  m.noremap('v', 'p', 'P', "Paste without yanking the deleted text")

  -- Retain the visual selection after indent lines
  m.noremap('v', '>', '>gv', 'Indent line(s) more')
  m.noremap('v', '<', '<gv', 'Indent line(s) less')

  -- Move visual block
  m.noremap('v', 'J', ":m '>+1<cr>gv=gv", "Move visual block up")
  m.noremap('v', 'K', ":m '<-2<cr>gv=gv", "Move visual block down")

  -- The highest keybind priority
  -- m.noremap('n', 'H', '<C-w>W', "Switch to preview window")

  m.noremap('',  'f', '<cmd>HopChar1CurrentLineAC<cr>')
  m.noremap('',  'F', '<cmd>HopChar1CurrentLineBC<cr>')
  m.noremap('',  'j', 'gj')
  m.noremap('',  'k', 'gk')
  m.noremap('',  '0', 'g0')
  m.noremap('',  '$', 'g$')
  m.noremap('',  '^', 'g^')
  m.noremap({'n', 'v', 'i'},  '<S-Up>', '<C-u>')
  m.noremap({'n', 'v', 'i'},  '<S-Down>', '<C-d>')

  -------------------
  -- Direct Keymap --
  -------------------
  --- action: switch
  --- <TAB> = <C-i> that could makes pause while using <C-i>
  m.noremap('n', '<leader>\\', '<C-w>w', "Switch to next window")
  m.noremap('n', '<leader><Left>', '<C-w>h', "Switch to left window")
  m.noremap('n', '<leader><Down>', '<C-w>j', "Switch to down window")
  m.noremap('n', '<leader><Up>', '<C-w>k', "Switch to up window")
  m.noremap('n', '<leader><Right>', '<C-w>l', "Switch to right window")
  m.noremap('n', '<leader><S-TAB>', '<cmd>BufferLineCyclePrev<cr>', "Switch to previous buffer")
  m.noremap('n', '<leader><TAB>', '<cmd>BufferLineCycleNext<cr>', "Switch to next buffer")

  -- There are two different clipboards for Linux and only one for Win
  -- *: clipboard for copy-on-select
  -- +: clipboard for <C-c> and <C-v>
  m.noremap('',  '<leader>p', '"+p', "Paste from Clipboard")
  m.noremap('',  '<leader>P', '"*p', "Paste from 'copy-on-select' Clipboard")
  m.noremap('n', '<leader>S', '<cmd>AerialToggle<cr>', 'Symbol Manager')
  m.noremap('n', '<leader>F', '<cmd>lua MiniFiles.open()<cr>', 'File Explorer')
  m.noremap('n', '<leader>d', M.close_buf, "Close current buffer")

  -------------------
  -- Folded Keymap --
  -------------------
  wk.setup()
  -- NOTE: need explicity declaration if override g, s, c, d, =, etc.
  wk.add({
    {
      mode = '',
      group = 'default',
      remap = false,
    },
    {
      group = "Extra Cmd G",
      { 'g0', '^', desc = "Go to the first character of line" },
      { 'g9', '$', desc = "Go to the end of line" },
      { 'g/', '<cmd>HopPattern<cr>' },
    },
    {
      group = "Change",
      { 'c', 'c', desc = "Change" },
      { 'c!', '<cmd>ToggleAlternate<cr>', desc = "Invert boolean value" },
    },
    {
      group = "Delete",
      { 'd', 'd', desc = "Delete" },
      { 'ds', '<cmd>lua MiniTrailspace.trim()<cr>', desc = 'Remove trailing spaces'}
    },
    {
      group = "Format",
      { '=', '=', desc = "Format" },
      { '==', '<cmd>lua vim.lsp.buf.format({ async = true })<cr>', desc = "LSP: Format" },
    },
    {
      group = "Yank",
      { 'y', 'y', desc = "Yank" },
      { 'ys', '"+y', desc = "Copy to Clipboard" },
      { 'yc', '"*y', desc = "Copy to 'copy-on-select' Clipboard" },
    },
    {
      group = "Search",
      mode = { 'n' },

      -- action: search
      { '/', '/', desc = "Fearch" },
      {
        '//',
        function()
          require("telescope").extensions.egrepify.egrepify({
            attach_mappings = grep_string_open,
          })
        end,
        desc = "Grep under CWD (Telescope)"
      },
      {
        '//w',
        function()
          require("telescope").extensions.egrepify.egrepify({
            default_text = string.format("\\b%s\\b", vim.fn.expand('<cword>')),
            attach_mappings = grep_string_open,
          })
        end,
        desc = "Search <cword> under CWD (Telescope)"
      },
      {
        '//f',
        function()
          require("telescope").extensions.egrepify.egrepify({
            search_dirs = { vim.fn.expand('%:p') },
            attach_mappings = grep_string_open,
          })
        end,
        desc = "Search in current buffer (Telescope)"
      },
      {
        '//c',
        function()
          require("telescope").extensions.egrepify.egrepify({
            search_dirs = { vim.fn.expand('%:p') },
            default_text = string.format("\\b%s\\b", vim.fn.expand('<cword>')),
            attach_mappings = grep_string_open,
          })
        end,
        desc = "Search current cursor string (Quickfix)"
      },
      { mode = 'v', '/', '<Esc>/\\%V', desc = "Search within selected block"},
    },
    {
      group = "Debug / Compile",
      mode = "n",
      { '<leader>\'b', desc = "<cmd>DapToggleBreakpoint<cr>" },
      { '<leader>\'c', desc = "<cmd>DapContinue<cr>" },
      { '<leader>\'s', desc = "<cmd>DapStepOver<cr>" },
      { '<leader>\'i', desc = "<cmd>DapStepInto<cr>" },
      { '<leader>\'o', desc = "<cmd>DapStepOut<cr>" },
      { '<leader>\'t', desc = "<cmd>DapToggleRepl<cr>" },
    },
    {
      group = "Coding",
      mode = "n",
      { "<leader>;r", function ()
        exe_loop({
          { id = 'glance', action = 'Glance references' },
          { id = 'trouble', action = 'Trouble lsp_references toggle' }
        })
      end, desc = "Code Reference" },
      { '<leader>;d', function ()
        exe_loop({
          { id = 'glance', action = 'Glance definitions' },
          { id = 'trouble', action = 'Trouble lsp_definitions toggle' }
        })
      end, desc = "Definition" },
      { '<leader>;D', function ()
        exe_loop({
          { id = 'glance', action = 'Glance type_definitions' },
          { id = 'trouble', action = 'Trouble lsp_type_definitions toggle' }
        })
      end, desc = "Type Definition" },
      { '<leader>;p', function ()
        exe_loop({
          { id = 'glance', action = 'Glance implementations' },
          { id = 'trouble', action = 'Trouble lsp_implementations toggle' }
        })
      end, desc = "Implementations" },
      { '<leader>;n', lsp.rename, desc = "Rename (LSP)" },
      { '<leader>;c', lsp.code_action, desc = "Show code action menu (LSP)" },
      { '<leader>;v', lsp.hover, desc = "Show info (LSP)" },
      { '<leader>;h', lsp.signature_help, desc = "Show signatures (LSP)" },
      { '<leader>;w', '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = "Diagnostic Workspace (Trouble)" },
      { '<leader>;f', '<cmd>TroubleToggle document_diagnostics<cr>', desc = "Diagnostic Document (Trouble)" },
    },
    {
      group = "File",
      mode = "n",
      { '<leader>fr', '<cmd>Telescope oldfiles<cr>', desc = "Open recently closed files" },
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = "Open files" },
      { '<leader>fw', '<cmd>w<cr>', desc = "Save" },
      -- { '<leader>fm', '<cmd>Bdelete menu<cr>', desc = "Show delete menu" },
      -- { '<leader>fD', '<cmd>Bdelete select<cr>', desc = "Select" },

    },
    {
      group = "Setup / Status",
      mode = "n",
      { '<leader>sa', lsp.add_workspace_folder, desc = "Add LSP workspace" },
      { '<leader>sr', lsp.remove_workspace_folder, desc = "Remove LSP workspace" },
      { '<leader>sw', function()
        -- TODO: Add to quickfix list
        print(vim.inspect(lsp.list_workspace_folders()))
      end, desc = "Show LSP workspace" },
      { '<leader>st', '<cmd>Telescope filetypes<cr>', desc = "Change filetypes" },
      { '<leader>sl', '<cmd>Mason<cr>', desc = "Mason: Main Menu" },
      { '<leader>sp', '<cmd>Lazy<cr>', desc = "Lazy: Main Menu" },
      { '<leader>si', '<cmd>LspInfo<cr>', desc = "LSP Server Info (LspInfo)" },
      { '<leader>sm', '<cmd>AerialInfo<cr>', desc = 'Symbol Manager Info (AerialInfo)' },
      { '<leader>sg', '<cmd>GuessIndent<cr>', desc = 'Set up indent (GuessIndent)' },
      { '<leader>sc', M.change_cwd, desc = "Set CWD to current buffer" },
      { '<leader>sC', '<cmd>Telescope cder<cr>', desc = "Change CWD with specified path" },
      { '<leader>sf', M.show_file_info, desc = "Show File and CWD info" },
      { '<leader>sr', M.reload_settings, desc = "Reload init.lua" },
      { '<leader>s,', M.edit_settings, desc = "Edit runtime init.lua" },
      -- { '<leader>sm', '<cmd>Outline<cr>', 'Toggle Outline Symbol Manager' },
      -- { '<leader>si', '<cmd>OutlineStatus<cr>', 'Get Outline Symbol Manager info' },
      {'<leader>st', '<cmd>Telescope builtin include_extensions=true<cr>', desc = "Telescope: Main Menu"},
      {"<leader>sq", '<cmd>TroubleToggle quickfix<cr>', desc = "Trouble: Toggle Quickfix"},
      {"<leader>sQ", '<cmd>TroubleToggle loclist<cr>', desc = "Trouble: Toggle Quickfix"},
      {'<leader>sr', '<cmd>Telescope registers<cr>', desc = "Open registers"},
    },
    {
      group = "Window",
      mode = 'n',
      {'<leader>wo', '<cmd>only<cr>', desc = "Close all other windows"},
    },
    {
      group = "Git",
      mode = "n",
      -- {'n', '<leader>;;b', '<cmd>Gitsigns blame_line<cr>', "Blame file (inline)"}
      {'<leader>gB', '<cmd>Gitsigns blame<cr>', desc = "Blame file"},
      {'<leader>g;', '<cmd>TigBlame<cr>', desc = "Blame file"},
      {'<leader>g.', '<cmd>TigOpenCurrentFile<cr>', desc = "Git log with current file"},
      {'<leader>g/', '<cmd>TigOpenProjectRootDir<cr>', desc = "Tig: Project Root Dir"},
      {'<leader>gp', '<cmd>Gitsigns preview_hunk_inline<cr>', desc = "Preview line change(s)"},
      {'<leader>gd', '<cmd>Gitsigns diffthis<cr>', desc = "Open two panes to show the diff"},
      {'<leader>gl', '<cmd>Gitsigns setloclist<cr>', desc = "List the change(s)"},
      {'<leader>gr', '<cmd>Gitsigns reset_hunk<cr>', desc = "Reset the hunk"},
      {'<leader>ga', '<cmd>Gitsigns stage_hunk<cr>', desc = "Add the hunk"},
    },
  })

  m.noremap('n', '<leader>b', '<cmd>Telescope buffers<cr>', "Switch opened buffers")
  m.noremap('n', '<leader>?', '<cmd>Telescope keymaps<cr>', "Open keymaps")
  m.noremap('n', '<leader>h', '<cmd>Telescope help_tags<cr>', "Show help manuals like :help")
  -- File (Open/Close/Save)
  -- m.noremap('n', '<leader>', '', "Open file (Current file path)")

end

return { -- Display cheat sheet of vim shortcut
  'folke/which-key.nvim',
  dependencies = {
    -- FIXME:
    -- Check dependencies
    -- For now, we use vim command to avoid dependency problems
  },
  config = config
}
