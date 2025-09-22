local vim = vim
local fn = vim.fn
local m = require("core.utils")

-- Show information about the current file
local show_file_info = function()
  vim.notify(string.format('File: %s\nCWD:  %s',
      vim.fn.expand('%:p'), vim.fn.getcwd()))
end

-- Change the current working directory to the file's directory
local change_cwd = function()
  vim.cmd('lcd %:p:h')
  vim.notify('Set CWD to ' .. vim.fn.getcwd())
end

-- Reload the Neovim configuration
local reload_settings = function()
  vim.cmd('source $MYVIMRC')
  vim.notify('Reload: ' .. vim.env.MYVIMRC)
end

-- Update the Neovim configuration
local edit_settings = function()
  vim.cmd('edit $MYVIMRC')
  m.autocmd('BufDelete', vim.env.MYVIMRC, function()
    vim.cmd('source ' .. vim.env.MYVIMRC)
    vim.notify('Reload: ' .. vim.env.MYVIMRC)
  end, {
    group = m.augroup('NvimSetup')
  })
end

local show_lsp_workspace = function()
  local folders = vim.lsp.buf.list_workspace_folders()

  if not folders or vim.tbl_isempty(folders) then
    vim.notify("No LSP workspace folders found", vim.log.levels.WARN)
    return
  end

  local items = {}
  for _, f in ipairs(folders) do
    table.insert(items, {
      filename = f,
      lnum = 1,
      col = 1,
      text = "LSP Workspace Folder"
    })
  end

  vim.fn.setqflist(items, 'r') -- replace quickfix list
  vim.cmd("copen")
end

-- Save buffer content if modifiable is 'on'
local quit = function()
  -- Get listed buffer
  local listed_buffers = fn.getbufinfo({buflisted = 1})
  local cur_bufnr = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(cur_bufnr)
  local is_listed = false
  local is_side_win = false

  -- Check if current bufnr is in listed buffers
  for _, buf in ipairs(listed_buffers) do
    if buf.bufnr == cur_bufnr then
      is_listed = true
      break
    end
  end

  -- Prevent cases like diff window
  if name:match("^[%a]+://") then
    is_side_win = true
  end

  -- TODO: Check diff mode
  -- 1. Close all other diff side windows
  -- 2. Change back to primary window

  if is_listed then
    if vim.bo.modifiable and not is_side_win then
      -- Close current buffer, load next buffer, and keep window position
      -- Usually, it would use in the main window
      vim.cmd('lua MiniBufremove.delete(0)')
    else
      -- Close current buffer, load next buffer, and destroy current window
      vim.cmd('silent! bdelete!')
    end

    -- Close all windows when current buffer is the last buffer and window
    if #listed_buffers <= 1 then
      vim.cmd('confirm quitall')
    end
  else
    -- If this is a hidden buffer, usually it's from certain plugin
    -- Keep buffer and close current window (or exit vim)
    vim.cmd('quit!')
  end
end

local function smart_man_pages()
  local builtin = require("telescope.builtin")
  local ft = vim.bo.filetype
  local word = vim.fn.expand("<cword>")
  local sections

  if ft == "sh" or ft == "bash" or ft == "zsh" or ft == "fish" then
    -- 使用者命令、系統管理命令；也順帶把 POSIX 1p 放進來
    sections = { "1", "8", "1p" }
  elseif ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" then
    -- C 函式庫優先，其次系統呼叫；也加上 POSIX 3p
    sections = { "3", "2", "3p", "9", "4"  }
  else
    -- 其他語言就不過濾
    sections = { "ALL" }
  end

  builtin.man_pages({
    default_text = (word ~= "" and word) or nil,
    sections = sections,
  })
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

  local telescope = require("telescope")
  local builtin = require("telescope.builtin")
  local actions = require("telescope.actions")
  local a_state = require("telescope.actions.state")

  -- 小工具 function，顯示當前 buffer 的 LSP root_dir
  local function show_lsp_root()
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    if #clients == 0 then
      print("No LSP client attached")
      return
    end
    for _, client in ipairs(clients) do
      print(client.name .. " → " .. client.config.root_dir)
    end
  end

  function open_file(prompt_bufnr, map)
    actions.select_default:replace(function()
      local selection = a_state.get_selected_entry()
      actions.close(prompt_bufnr)
      if selection and selection.path then
        -- 用 :edit 開啟檔案，而不是 buffer switch
        vim.cmd("edit " .. vim.fn.fnameescape(selection.path))
      end
      -- 延遲執行，等 buffer attach 好
      vim.schedule(show_lsp_root)
    end)
    return true
  end

  function wa_open_file(prompt_bufnr, map)
    actions.select_default:replace(function()
      local entry = a_state.get_selected_entry()
      actions.close(prompt_bufnr)
      -- 在 cmdline 填入 :edit {filename}
      vim.defer_fn(function()
        vim.api.nvim_feedkeys(":edit " .. vim.fn.fnameescape(entry.path), "n", false)
      end, 10)
    end)
    return true
  end

  function grep_string_open(prompt_bufnr, map)
    actions.select_default:replace(function()
      -- 先取得選擇的 entry
      local entry = a_state.get_selected_entry()
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

  -- 1) 轉義 PCRE/rg 的特殊字元
  function escape_regex(s)
    return s:gsub("([\\.^$|?*+()%[%]{}])", "\\%1")
  end

  -- 2) 清理選取文字：去除/壓縮換行、Tab、回車等
  --    mode = "collapse"：把所有空白（含 \n \t \r）壓成單一空白
  --    mode = "strip"   ：直接移除所有空白（含 \n \t \r）
  function sanitize_selection(s, mode)
    -- 把常見 escape 寫法的字面 "\n"、"\t"、"\r" 也一併處理
    s = s:gsub("\\[ntr]", " ")  -- 文字中出現的 \n \t \r → 空白
    if mode == "strip" then
      s = s:gsub("[%s%c]+", "") -- 移除所有空白/控制字元
    else
      s = s:gsub("[%s%c]+", " ") -- 壓成單一空白（預設）
      s = s:gsub("^%s+", ""):gsub("%s+$", "")
    end
    return s
  end

  --- mk_search(opts) 產生一個可綁定的函式
  --- opts:
  ---   - current_file : boolean   在目前檔案內搜尋
  ---   - search_dirs         : {string}  自訂搜尋目錄/檔案
  ---   - sanitize            : "collapse" | "strip"  預設 "collapse"
  function mk_search(opts)
    return function()
      local text
      if vim.fn.mode():find("[vV\022]") then
        vim.cmd('normal! "zy')      -- 視覺選取 → 放進 "z
        text = vim.fn.getreg("z")
      else
        text = vim.fn.expand("<cword>")
      end

      -- 忽略/處理換行等空白：把它們壓成單一空白（你也可改成 "strip"）
      text = sanitize_selection(text, "collapse")
      text = escape_regex(text)

      if text == "" then return end
      local patt = text:match("^%w+$") and ("\\b"..text.."\\b") or text
      local args = {
        default_text = patt,
        attach_mappings = grep_string_open,
      }
      if opts.current_file then
        args.search_dirs = { vim.fn.expand("%:p") }
      end
      require("telescope").extensions.egrepify.egrepify(args)
    end
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
      -- m.noremap('n', '<leader>q', '<cmd>diffoff | only<cr>', "Back to Normal edit mode")
    end

    if not vim.o.modifiable then
      -- Using :quit instead of :close is because :quit could exit nvim
      -- once the current buffer is the last buffer
      m.noremap('n', 'q', quit, "Close Buffer", { buffer = true })
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
  m.noremap({'i', 'n', 'v'}, '<C-c>', '<Esc>', "<ESC>")
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
  -- Folded Keymap --
  -------------------
  wk.setup()
  -- NOTE: need explicity declaration if override g, s, c, d, =, etc.
  wk.add({
    {
      mode = 'n',
      group = 'Direct Keymap',
      remap = false,
      { '<leader>.', '<cmd>only<cr>', desc = "Close All Other Windows"},
      { '<leader>.t', '<cmd>tabonly<cr>', desc = "Close All Other Tabs"},
      { '<leader>x', '<cmd>close<cr>', desc = "Close Current Window"},
      { '<leader>q', quit, desc = "Close Current Buffer and Window"},
      { '<leader>[', '<cmd>Telescope buffers<cr>', desc = "Switch opened buffers"},
      { '<leader>K', function ()
        builtin.help_tags({ default_text = vim.fn.expand('<cword>') })
      end, desc = "Show help manuals like :help" },
      { '<leader>M', smart_man_pages, desc = "Show Man manuals like :Man" },

      -- There are two different clipboards for Linux and only one for Win
      -- *: clipboard for copy-on-select
      -- +: clipboard for <C-c> and <C-v>
      {  '<leader>ps', '"+p', desc = "Paste from Clipboard"},
      {  '<leader>Ps', '"+P', desc = "Paste from Clipboard"},
      {  '<leader>pc', '"*p', desc = "Paste from 'copy-on-select' Clipboard"},
      {  '<leader>Pc', '"*P', desc = "Paste from 'copy-on-select' Clipboard"},

      --- action: switch
      --- <TAB> = <C-i> that could makes pause while using <C-i>
      { '<leader>\\', '<C-w>w', desc = "Switch to next window"},
      { '<leader><Left>', '<C-w>h',desc = "Switch to left window"},
      { '<leader><Down>', '<C-w>j',desc = "Switch to down window"},
      { '<leader><Up>', '<C-w>k', desc = "Switch to up window"},
      { '<leader><Right>', '<C-w>l', desc = "Switch to right window"},
      { '<leader><S-TAB>', '<cmd>BufferLineCyclePrev<cr>', desc = "Switch to previous buffer"},
      { '<leader><TAB>', '<cmd>BufferLineCycleNext<cr>', desc = "Switch to next buffer"},

      { '<leader>d', quit, desc = "Close current buffer"},
    },
    {
      group = "Extra Cmd G",
      { 'g0', '^', desc = "Go to the first character of line" },
      { 'g9', '$', desc = "Go to the end of line" },
      { 'g/', '<cmd>HopPattern<cr>' },
      { "g[", function ()
        exe_loop({
          { id = 'trouble', action = 'Trouble lsp_outgoing_calls toggle' },
          { id = 'telescope', action = 'Telescope lsp_incoming_calls' },
        })
      end, desc = "LSP: Incoming Calls" },
      { "g]", function ()
        exe_loop({
          { id = 'trouble', action = 'Trouble lsp_incoming_calls toggle' },
          { id = 'telescope', action = 'Telescope lsp_outgoing_calls' },
        })
      end, desc = "LSP: Outgoing Calls" },
      { "gr", function ()
        exe_loop({
          { id = 'trouble', action = 'Trouble lsp_references toggle' },
          { id = 'telescope', action = 'Telescope lsp_references' },
          { id = 'coc', action = "<Plug>(coc-references)" },
          { id = 'glance', action = 'Glance references' },
        })
      end, desc = "Code Reference" },
      { 'gd', function ()
        exe_loop({
          { id = 'trouble', action = 'Trouble lsp_definitions toggle' },
          { id = 'telescope', action = 'Telescope lsp_definitions' },
          { id = 'coc', action = "<Plug>(coc-definition)" },
          { id = 'glance', action = 'Glance definitions' },
        })
      end, desc = "Definition" },
      { 'gD', function ()
        exe_loop({
          { id = 'trouble', action = 'Trouble lsp_type_definitions toggle' },
          { id = 'telescope', action = 'Telescope lsp_type_definitions' },
          { id = 'coc', action = "<Plug>(coc-type-definition)" },
          { id = 'glance', action = 'Glance type_definitions' },
        })
      end, desc = "Type Definition" },
      { 'gp', function ()
        exe_loop({
          { id = 'trouble', action = 'Trouble lsp_implementations toggle' },
          { id = 'telescope', action = 'Telescope lsp_implementations' },
          { id = 'coc', action = "<Plug>(coc-implementation)" },
          { id = 'glance', action = 'Glance implementations' },
        })
      end, desc = "Implementations" },
      { 'go', "<cmd>DapStepOver<cr>", desc = "DAP: Step Over" },
      { 'g>', "<cmd>DapStepInto<cr>", desc = "DAP: Step In" },
      { 'g<', "<cmd>DapStepOut<cr>", desc = "DAP: Step Out"},
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
      mode = { 'n', 'v' },
      group = "Yank",
      { 'ys', '"+y', desc = "Copy to Clipboard" },
      { 'yc', '"*y', desc = "Copy to 'copy-on-select' Clipboard" },
    },
    {
      group = "Search",
      mode = { 'n' },

      -- action: search
      { '/', '/', desc = "Search" },
      {
        '//', function()
          telescope.extensions.egrepify.egrepify({
            attach_mappings = grep_string_open,
          })
        end, desc = "Grep under CWD"
      },
      {
        '//f', function()
          telescope.extensions.egrepify.egrepify({
            search_dirs = { vim.fn.expand('%:p') },
            attach_mappings = grep_string_open,
          })
        end, desc = "Grep in current file"
      },
      {
        '//w', mk_search({}),
        mode = {"n", "x"},
        desc = "Grep <cword> under CWD"
      },
      {
        '//c', mk_search({ current_file = true }),
        mode = {"n", "x"},
        desc = "Grep <cword> in current file"
      },
      { mode = 'v', '/', '<Esc>/\\%V', desc = "Search within selected block"},
    },
    {
      group = "LSP",
      mode = "n",
      { '<leader>;t', desc = "<cmd>DapToggleBreakpoint<cr>" },
      { '<leader>;c', desc = "<cmd>DapContinue<cr>" },
      { '<leader>;t', desc = "<cmd>DapToggleRepl<cr>" },
      { '<leader>;m', lsp.code_action, desc = "Show code action menu (LSP)" },
    },
    {
      group = "File",
      mode = "n",
      {
        '<leader>ff', function()
          builtin.find_files({
            attach_mappings = open_file,
            -- cwd = require('lspconfig.util').root_pattern(".git", '.root')(vim.fn.expand("%:p")) or vim.loop.cwd()
            cwd = false,
          })
        end, desc = "Open files"
      },
      {
        '<leader>fr', function()
          builtin.oldfiles({
            attach_mappings = open_file,
            -- cwd = require('lspconfig.util').root_pattern(".git", '.root')(vim.fn.expand("%:p")) or vim.loop.cwd()
            cwd = false,
          })
        end, desc = "Open Recently Closed Files"
      },
      { '<leader>fw', '<cmd>w<cr>', desc = "Save" },
      -- { '<leader>fm', '<cmd>Bdelete menu<cr>', desc = "Show delete menu" },
      -- { '<leader>fD', '<cmd>Bdelete select<cr>', desc = "Select" },
      { '<leader>ft', '<cmd>Telescope filetypes<cr>', desc = "Change File Type" },
    },
    {
      group = "Show / Set",
      -- Unbind 's' since it can be replaced by 'cl'
      -- Fix recursive keybind s -> <leader>s and no menu s -> <Nop> problem
      { 's', function ()
        require("which-key").show("<leader>s", { mode = "n" })
      end, desc = "Show", remap = false },
      { 'ss', '<Nop>' },
      { 's<C-c>', '<Nop>' },

      { '<leader>si', '<cmd>LspInfo<cr>', desc = "LSP Server Info (LspInfo)" },
      { '<leader>sm', '<cmd>AerialInfo<cr>', desc = 'Symbol Manager Info (AerialInfo)' },
      { '<leader>sh', function()
        lsp.hover({
          border = "rounded", -- Choose your border style here
          -- max_width = 120,   -- Optional: Set a maximum width
          -- max_height = 25,   -- Optional: Set a maximum height
        })
      end, desc = "LSP: Show Symbol Info" },
      { '<leader>sH', function ()
        lsp.signature_help({ border = "rounded" })
      end, desc = "LSP: Show Signature Help" },
      { '<leader>sd', '<cmd>Gitsigns preview_hunk_inline<cr>', desc = "Preview line change(s)"},
      { '<leader>sD', '<cmd>Gitsigns setloclist<cr>', desc = "List the change(s)"},
      { '<leader>sb', '<cmd>Gitsigns blame_line<cr>', desc = "Blame Line"},
      { '<leader>sB', '<cmd>Gitsigns blame<cr>', desc = "Blame File"},
      { '<leader>sg', '<cmd>GuessIndent<cr>', desc = 'Set up indent (GuessIndent)' },
      { '<leader>sp', show_file_info, desc = "Show File Path and CWD Path" },
      { '<leader>sP', change_cwd, desc = "Set CWD to current buffer" },
      { '<leader>s.', '<cmd>Telescope cder<cr>', desc = "Change CWD with specified path" },
      { '<leader>s+', lsp.add_workspace_folder, desc = "LSP: Add LSP Workspace Dir" },
      { '<leader>s-', lsp.remove_workspace_folder, desc = "LSP: Remove LSP Workspace Dir" },
      { '<leader>sl', show_lsp_workspace, desc = "LSP: Show LSP Workspace Dir" },
      { '<leader>s!', '<cmd>Gitsigns toggle_current_line_blame<cr>', desc = "Preview line change(s)"},
      -- check mini.lua
    },
    {
      group = "Edit",
      { '<leader>ca', '<cmd>Gitsigns stage_hunk<cr>', desc = "Add the hunk"},
      { '<leader>cs', '<cmd>Gitsigns reset_hunk<cr>', desc = "Reset the hunk"},
      { '<leader>cn', lsp.rename, desc = "Rename (LSP)" },
      -- check mini.lua
    },
    {
      group = "Menu",
      mode = "n",
      { '<leader><space>l', '<cmd>Mason<cr>', desc = "Mason: Main Menu" },
      { '<leader><space>p', '<cmd>Lazy<cr>', desc = "Lazy: Main Menu" },
      { '<leader><space>t', '<cmd>Telescope builtin include_extensions=true<cr>', desc = "Telescope: Main Menu"},
      { '<leader><space>h', '<cmd>Telescope help_tags<cr>', desc = "Help Manuals"},
      { '<leader><space>m', '<cmd>Telescope man_pages sections=ALL<cr>', desc = "Manuals"},
      { '<leader><space>k', '<cmd>Telescope keymaps<cr>', desc = "Keymaps" },
      -- { '<leader>sm', '<cmd>Outline<cr>', 'Toggle Outline Symbol Manager' },
      -- { '<leader>si', '<cmd>OutlineStatus<cr>', 'Get Outline Symbol Manager info' },
      -- { "<leader><space>q", '<cmd>TroubleToggle quickfix<cr>', desc = "Trouble: Toggle Quickfix"},
      -- { "<leader><space>Q", '<cmd>TroubleToggle loclist<cr>', desc = "Trouble: Toggle Quickfix"},
      -- {'<leader>sr', '<cmd>Telescope registers<cr>', desc = "Open registers"},
      -- { '<leader><space>w', '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = "Diagnostic Workspace (Trouble)" },
      -- { '<leader><space>f', '<cmd>TroubleToggle document_diagnostics<cr>', desc = "Diagnostic Document (Trouble)" },
      { '<leader><space>b', '<cmd>TigBlame<cr>', desc = "Blame file"},
      { '<leader><space>c', '<cmd>TigOpenCurrentFile<cr>', desc = "Git log with current file"},
      { '<leader><space>r', '<cmd>TigOpenProjectRootDir<cr>', desc = "Tig: Project Root Dir"},
      { '<leader><space>s', '<cmd>AerialToggle<cr>', desc = 'Symbol Manager'},
      { '<leader><space>f', '<cmd>lua MiniFiles.open()<cr>', desc = 'File Explorer'},
    },
  })

  -- m.noremap('n', '<leader>K', '<cmd>Telescope help_tags<cr>', "Show help manuals like :help")
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
