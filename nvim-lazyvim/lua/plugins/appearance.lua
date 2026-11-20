return {
  {
    "marko-cerovac/material.nvim",
    opts = { async_loading = false },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "material-darker" },
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = true },
      -- Mini Files handles directory buffers. Snacks Explorer still has its keys.
      explorer = { replace_netrw = false },
      -- Mini Indentscope owns the legacy indentation guide.
      indent = { enabled = false },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = "powerline"
      opts.options.component_separators = { left = "", right = "" }
      opts.options.section_separators = { left = "", right = "" }
      opts.sections.lualine_c = {
        {
          "tabs",
          mode = 1,
          use_mode_colors = true,
          show_modified_status = false,
          fmt = function(_, context)
            local tab = vim.api.nvim_list_tabpages()[context.tabnr]
            return context.tabnr .. ":" .. (tab and vim.t[tab].name or "*")
          end,
        },
        { "filename", path = 1, symbols = { modified = "[M]", readonly = "[RO]" } },
        function()
          local register = vim.fn.reg_recording()
          return register == "" and "" or "REC @" .. register
        end,
      }
      vim.list_extend(opts.sections.lualine_x, { "searchcount", "encoding", "fileformat", "filetype" })
    end,
  },
}
