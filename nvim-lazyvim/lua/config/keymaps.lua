local M = {}

M.which_key_groups = {
  { "<leader><space>", group = "Menu", mode = { "n", "x" } },
}

-- Direct Keymap: yank and put.
M.yanky_keys = {
  { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
  { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after" },
  { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before" },
  -- Menu: open the history picker from Space–Space.
  { "<leader><space>y", "<cmd>Telescope yank_history<cr>", mode = { "n", "x" }, desc = "Yank history" },
}

-- Search: Telescope grep and picker-local bindings.
-- Telescope actions used by the grep and picker mappings below.
-- WA for multi-selections
-- https://github.com/nvim-telescope/telescope.nvim/issues/1048
local function select_one_or_multi(prompt_bufnr)
  local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not vim.tbl_isempty(multi) then
    require('telescope.actions').close(prompt_bufnr)
    for _, j in pairs(multi) do
      if j.path ~= nil then
        vim.cmd.edit({ args = { j.path }, magic = { file = false } })
      end
    end
  else
    require('telescope.actions').select_default(prompt_bufnr)
  end
end

local function grep(prompt, current_file)
  return function()
    local opts = { cwd = vim.fn.getcwd() }
    if current_file then
      local path = vim.api.nvim_buf_get_name(0)
      if vim.bo.buftype ~= "" or path == "" then
        return
      end
      opts.search_dirs = { path }
    end
    if prompt then
      local mode = vim.fn.mode()
      local text = vim.fn.expand("<cword>")
      if mode == "v" or mode == "V" or mode == "\22" then
        local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
        text = vim.trim(table.concat(lines, " "):gsub("%s+", " "))
      end
      if text == "" then
        return
      end
      opts.default_text = text:gsub("([\\.^$|?*+()%[%]{}])", "\\%1")
    end
    require("telescope").extensions.egrepify.egrepify(opts)
  end
end

M.telescope_keys = {
  -- In nvim/core/which-key.lua, <leader>ff searched the cwd and <leader>ft
  -- picked a filetype. LazyVim uses them for root files and a root terminal.
  { "<leader>[", "<cmd>Telescope buffers<cr>", desc = "Switch buffer" },
  { "//", grep(false, false), desc = "Grep (cwd)" },
  { "//f", grep(false, true), desc = "Grep current file" },
  { "//w", grep(true, false), mode = { "n", "x" }, desc = "Grep word or selection (cwd)" },
  { "//c", grep(true, true), mode = { "n", "x" }, desc = "Grep word or selection in current file" },
}

function M.telescope_mappings()
  local actions = require("telescope.actions")
  local action_layout = require("telescope.actions.layout")
  local egrep_actions = require("telescope._extensions.egrepify.actions")
  return {
    preview = {
      i = { ["<C-p>"] = action_layout.toggle_preview },
      n = { ["<C-p>"] = action_layout.toggle_preview },
    },
    defaults = {
      i = {
        ["<CR>"] = select_one_or_multi,
        ["<c-p>"] = action_layout.toggle_preview,
        ["<c-o>"] = action_layout.toggle_mirror,
        ["<c-s>"] = actions.select_horizontal,
        ["<c-v>"] = actions.select_vertical,
        ["<c-u>"] = actions.results_scrolling_up,
        ["<c-d>"] = actions.results_scrolling_down,
        -- ["<c-h>"] = actions.results_scrolling_left,
        -- ["<c-l>"] = actions.results_scrolling_right,
        ["<c-up>"] = actions.preview_scrolling_up,
        ["<c-down>"] = actions.preview_scrolling_down,
        -- ["<c-left>"] = actions.preview_scrolling_left,
        -- ["<c-right>"] = actions.preview_scrolling_right,
        ["<esc>"] = actions.close,
        ["<c-?>"] = actions.which_key,
      },
      n = {
        ["<CR>"] = select_one_or_multi,
        ["<c-p>"] = action_layout.toggle_preview,
        ["<c-o>"] = action_layout.toggle_mirror,
        ["<c-s>"] = actions.select_horizontal,
        ["<c-v>"] = actions.select_vertical,
        ["<c-u>"] = actions.results_scrolling_up,
        ["<c-d>"] = actions.results_scrolling_down,
        -- ["<c-h>"] = actions.results_scrolling_left,
        -- ["<c-l>"] = actions.results_scrolling_right,
        ["<c-up>"] = actions.preview_scrolling_up,
        ["<c-down>"] = actions.preview_scrolling_down,
        -- ["<c-left>"] = actions.preview_scrolling_left,
        -- ["<c-right>"] = actions.preview_scrolling_right,
        ["<esc>"] = actions.close,
        ["<c-?>"] = actions.which_key,
      }
    },
    buffers = {
      i = {
        -- TODO: It won't delete current buffer
        ["<c-x>"] = actions.delete_buffer,
      }
    },
    egrepify = {
      i = {
        -- toggle prefixes, prefixes is default
        ["<C-z>"] = egrep_actions.toggle_prefixes,
        -- toggle AND, AND is default, AND matches tokens and any chars in between
        ["<C-a>"] = egrep_actions.toggle_and,
        -- toggle permutations, permutations of tokens is opt-in
        ["<C-r>"] = egrep_actions.toggle_permutations,
      },
    },
  }
end

-- Edit: Mini alignment, surrounds, commenting, and split/join.
M.mini_align_mappings = { start = "", start_with_preview = "c=" }
M.mini_align_keys = {
  { M.mini_align_mappings.start_with_preview, mode = { "n", "x" }, desc = "Align with preview" },
}

-- Legacy s[] and s% shared Flash's s prefix. LazyVim uses ]] and [[
-- for reference navigation, so the surround searches have their own keys.
M.mini_surround_mappings = {
  add = "c[]",
  delete = "d[]",
  replace = "cs",
  highlight = "c%",
  find = "<leader>c]",
  find_left = "<leader>c[",
  update_n_lines = "",
}

-- Legacy <leader>cc is LazyVim's LSP code lens action.
M.mini_comment_mappings = {
  comment = "",
  comment_line = "<leader>c/",
  comment_visual = "<leader>c/",
  textobject = "",
}

M.mini_splitjoin_mappings = { toggle = "<leader>J" }

-- Menu: plugin entry points under Space–Space.
M.mini_files_keys = {
  { "<leader><space>f", function() require("mini.files").open() end, desc = "File explorer (cwd)" },
}

M.aerial_keys = { { "<leader><space>s", "<cmd>AerialToggle<cr>", desc = "Symbol outline" } }

M.tig_keys = {
  { "<leader><space>b", "<cmd>TigBlame<cr>", desc = "Tig blame" },
  { "<leader><space>c", "<cmd>TigOpenCurrentFile<cr>", desc = "Tig file history" },
  { "<leader><space>g", "<cmd>TigOpenProjectRootDir<cr>", desc = "Tig project" },
}

M.codex_keys = {
  { "<leader><leader>o", function() require("codex").toggle() end, desc = "Toggle Codex" },
  { "<leader><leader>o", function() require("codex").actions.send_selection() end, mode = "x", desc = "Send selection to Codex" },
}

-- Plugin-local keys for yank history, the buffer list, and the jump list.
function M.yanky_telescope_mappings()
  local mapping = require("yanky.telescope.mapping")
  return {
    use_default_mappings = true, -- if default mappings should be used
    mappings = {
      default = mapping.set_register("+"),
      i = {
        ["<Tab>"] = mapping.put("p"),
        ["<S-Tab>"] = mapping.put("P"),
        ["<C-x>"] = mapping.delete(),
      },
    }, -- nil to use default mappings or no mappings (see `use_default_mappings`)
  }
end

M.vuffers_mappings = {
  use_default = true,
  -- key maps on the vuffers list
  view = {
    open = "<CR>",
    delete = "d",
    pin = "p",
    unpin = "P",
    rename = "r",
    reset_custom_display_name = "R",
    reset_custom_display_names = "<leader>R",
    move_up = "U",
    move_down = "D",
    move_to = "i",
  },
}

M.jumppack_mappings = {
  stop = 'q',
  toggle_preview = '<C-p>',
  toggle_cwd_filter = '.',
  toggle_show_hidden = 'h',
}

-- Fold: UFO's overrides of the built-in fold commands.
M.ufo_keys = {
  { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
  { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
  { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open one fold level" },
  { "zm", function() require("ufo").closeFoldsWith() end, desc = "Close one fold level" },
  { "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek folded lines" },
}

local function setup_global_mappings()
  -- See nvim/core/which-key.lua for the original bindings:
  -- Insert <C-s> ran one Normal-mode command, <leader>q closed buffers or diffs,
  -- <leader>x closed a window, and <leader>g jumped with Flash.
  -- LazyVim owns these keys and their prefixes in this profile.
  -- Legacy <leader>sb, <leader>sD, <leader>sg and <leader>sk were Git,
  -- indentation, or help actions. LazyVim uses them for picker actions.
  -- Legacy <leader>ca/<leader>cs staged/reset hunks and gd/gr used Trouble
  -- first. LazyVim owns its LSP and Git mappings.
  -- Legacy j/k always followed display lines and insert Alt-j/Alt-k moved
  -- the cursor. LazyVim keeps its count-aware j/k and Alt-j/Alt-k line moves.

  local mappings = {
    -- Direct Keymap
    -- Mode changes
    { "<C-c>", "<Esc>", mode = { "i", "n", "x", "s", "o", "c" }, desc = "Escape" },
    { "<Esc>", [[<C-\><C-n>]], mode = "t", desc = "Leave terminal mode" },
    -- Display lines, marks, and scrolling
    { "0", "g0", mode = { "n", "x" }, desc = "Start of display line" },
    { "$", "g$", mode = { "n", "x" }, desc = "End of display line" },
    { "^", "g^", mode = { "n", "x" }, desc = "First nonblank character of display line" },
    { "'", "`", mode = { "n", "x" }, desc = "Jump to exact mark position" },
    { "g'", "g`", mode = { "n", "x" }, desc = "Jump to exact mark position without adding a jump" },
    { "<S-Up>", "<C-u>", mode = { "n", "x" }, desc = "Scroll up" },
    { "<S-Down>", "<C-d>", mode = { "n", "x" }, desc = "Scroll down" },
    { "<C-x><C-x>", "<Esc>``a", mode = "i", desc = "Return to previous jump" },
    -- Shell-style editing
    { "<M-h>", "<Left>", mode = { "i", "c" }, desc = "Move left" },
    { "<M-l>", "<Right>", mode = { "i", "c" }, desc = "Move right" },
    { "<M-k>", "<Up>", mode = "c", desc = "Previous command" },
    { "<M-j>", "<Down>", mode = "c", desc = "Next command" },
    { "<M-w>", "<C-Right>", mode = { "i", "c" }, desc = "Move to next word" },
    { "<M-b>", "<C-Left>", mode = { "i", "c" }, desc = "Move to previous word" },
    { "<M-BS>", "<C-w>", mode = { "i", "c" }, desc = "Delete previous word" },
    { "<M-d>", "<C-o>dw", mode = "i", desc = "Delete next word" },
    { "<M-d>", "<C-Right><C-w>", mode = "c", desc = "Delete next word" },
    -- Clipboard
    { "p", "P", mode = "x", desc = "Paste without replacing the unnamed register" },
    { "<leader>y", '"+y', mode = { "n", "x" }, desc = "Copy to system clipboard" },
    { "<leader>Y", '"+Y', desc = "Copy line to system clipboard" },
    { "<leader>p", '"+p', desc = "Paste system clipboard after cursor" },
    { "<leader>P", '"+P', desc = "Paste system clipboard before cursor" },
    -- Windows, tabs, and buffers
    { "<leader>.", "<cmd>only<cr>", desc = "Close other windows" },
    { "<leader>.t", "<cmd>tabonly<cr>", desc = "Close other tabs" },
    { "<leader><Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<leader><S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },

    -- Extra Cmd G
    { "g9", "$", desc = "End of line" },
    { "g[", "<cmd>Telescope lsp_incoming_calls<cr>", desc = "LSP incoming calls" },
    { "g]", "<cmd>Telescope lsp_outgoing_calls<cr>", desc = "LSP outgoing calls" },
    { "go", "<cmd>DapStepOver<cr>", desc = "DAP step over" },
    { "g>", "<cmd>DapStepInto<cr>", desc = "DAP step into" },
    { "g<", "<cmd>DapStepOut<cr>", desc = "DAP step out" },

    -- Change
    { "c!", "<cmd>ToggleAlternate<cr>", desc = "Toggle alternate value" },

    -- Delete
    { "x", '"_x', mode = { "n", "x" }, desc = "Delete character without yanking" },
    { "X", '"_X', mode = { "n", "x" }, desc = "Delete previous character without yanking" },
    { "ds", function() require("mini.trailspace").trim() end, desc = "Trim trailing whitespace" },

    -- Format
    -- LazyVim provides <leader>cf. The old == mapping stays in the legacy config.

    -- Search
    { "/", "<Esc>/\\%V", mode = "x", desc = "Search within selection" },

    -- LSP
    -- LazyVim provides the core LSP maps. See Show / Set for workspace folders.

    -- File
    { "<leader>fw", "<cmd>write<cr>", desc = "Save" },

    -- Show / Set
    { "<leader>s.", "<cmd>Telescope cder<cr>", desc = "Pick working directory" },
    {
      "<leader>sP",
      function()
        local path = vim.api.nvim_buf_get_name(0)
        if vim.bo.buftype == "" and path ~= "" then
          vim.cmd.lcd({ args = { vim.fs.dirname(path) }, magic = { file = false } })
          vim.notify("Set CWD to " .. vim.fn.getcwd())
        end
      end,
      desc = "Set window CWD to file directory",
    },
    { "<leader>s+", vim.lsp.buf.add_workspace_folder, desc = "Add LSP workspace folder" },
    { "<leader>s-", vim.lsp.buf.remove_workspace_folder, desc = "Remove LSP workspace folder" },
    { "<leader>s!", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle line blame" },

    -- Edit
    { "J", ":m '>+1<cr>gv=gv", mode = "x", desc = "Move selection down" },
    { "K", ":m '<-2<cr>gv=gv", mode = "x", desc = "Move selection up" },

    -- Menu
    { "<leader><space>l", "<cmd>Mason<cr>", desc = "Manage language tools" },
    { "<leader><space>p", "<cmd>Lazy<cr>", desc = "Manage plugins" },
    { "<leader><space>t", "<cmd>Telescope builtin include_extensions=true<cr>", desc = "Telescope menu" },
    { "<leader><space>H", "<cmd>Telescope help_tags<cr>", desc = "Neovim help" },
    { "<leader><space>M", "<cmd>Telescope man_pages sections=ALL<cr>", desc = "Man pages" },
    { "<leader><space>k", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
  }

  -- Direct Keymap: switch windows with Alt in each editing mode.
  for key, direction in pairs({ Left = "h", Down = "j", Up = "k", Right = "l", ["\\"] = "w" }) do
    local lhs = "<M-" .. key .. ">"
    vim.list_extend(mappings, {
      { lhs, "<C-w>" .. direction, mode = { "n", "x", "o" }, desc = "Switch window" },
      { lhs, "<Esc><C-w>" .. direction, mode = "i", desc = "Switch window" },
      { lhs, [[<C-\><C-n><C-w>]] .. direction, mode = "t", desc = "Switch window" },
    })
  end

  require("which-key").add(mappings)

  -- Legacy <leader>sl listed LSP folders. LazyVim owns it for the location list.
  vim.api.nvim_create_user_command("LspWorkspaceFolders", function()
    local folders = vim.lsp.buf.list_workspace_folders()
    if #folders == 0 then
      vim.notify("No LSP workspace folders found", vim.log.levels.WARN)
      return
    end
    vim.fn.setqflist(vim.tbl_map(function(folder)
      return { filename = folder, lnum = 1, col = 1, text = "LSP Workspace Folder" }
    end, folders), "r")
    vim.cmd.copen()
  end, { desc = "List LSP workspace folders" })

  vim.api.nvim_create_user_command("TabName", function(args)
    vim.t.name = args.args
  end, { nargs = 1 })

  for lhs, rhs in pairs({ W = "w", Q = "q", Wa = "wa", Wq = "wq", wQ = "wq", WQ = "wq" }) do
    vim.cmd(("cnoreabbrev <expr> %s getcmdtype() == ':' && getcmdline() ==# '%s' ? '%s' : '%s'"):format(lhs, lhs, rhs, lhs))
  end
end

-- Plugin specs read this module early. Install global maps after LazyVim's defaults.
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimKeymaps",
  once = true,
  callback = setup_global_mappings,
})

return M
