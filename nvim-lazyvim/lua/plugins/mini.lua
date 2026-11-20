local keymaps = require("config.keymaps")

return {
  {
    "nvim-mini/mini.files",
    lazy = false,
    init = function()
      -- Mini Files clears this netrw group even when lazy.nvim disables netrw.
      vim.api.nvim_create_augroup("FileExplorer", { clear = false })
    end,
    opts = {
      windows = { preview = true, width_preview = 80 },
      options = { use_as_default_explorer = true },
    },
    keys = keymaps.mini_files_keys,
  },
  { "nvim-mini/mini.pick", cmd = "Pick", opts = {} },
  { "nvim-mini/mini.cursorword", event = "LazyFile", opts = {} },
  { "nvim-mini/mini.bufremove", opts = {} },
  {
    "nvim-mini/mini.indentscope",
    event = "LazyFile",
    opts = function()
      return { draw = { delay = 0, animation = require("mini.indentscope").gen_animation.none() } }
    end,
  },
  {
    "nvim-mini/mini.trailspace",
    opts = { only_in_normal_buffers = true },
    config = function(_, opts)
      local trailspace = require("mini.trailspace")
      trailspace.setup(opts)
      -- Start in the legacy viewer mode after Mini Trailspace initializes.
      vim.defer_fn(trailspace.unhighlight, 0)
    end,
  },
  {
    "nvim-mini/mini.align",
    keys = keymaps.mini_align_keys,
    opts = { mappings = keymaps.mini_align_mappings },
  },
  { "nvim-mini/mini.surround", opts = { mappings = keymaps.mini_surround_mappings } },
  { "nvim-mini/mini.comment", opts = { mappings = keymaps.mini_comment_mappings } },
  { "nvim-mini/mini.splitjoin", opts = { mappings = keymaps.mini_splitjoin_mappings } },
  {
    "nvim-mini/mini.animate",
    event = "VeryLazy",
    opts = function()
      local animate = require("mini.animate")
      return {
        resize = { enable = false },
        open = { enable = false },
        close = { enable = false },
        cursor = {
          enable = true,
          timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
        },
        scroll = {
          enable = false,
          timing = animate.gen_timing.linear({ duration = 10, unit = "total" }),
          subscroll = animate.gen_subscroll.equal({ max_output_steps = 5 }),
        },
      }
    end,
  },
}
