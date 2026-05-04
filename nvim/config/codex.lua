return {
  'rhart92/codex.nvim',
  lazy = true,
  -- May 4, 2026:
  -- 1. Codex only opens for plus and above memberships
  -- 2. Using API would be charged separately
  -- 3. This tool doesn't work with API interfaces
  opts = {
    split = "horizontal",
    size = 0.3,
    float = {
      width = 0.6,
      height = 0.6,
      border = "rounded",
      row = nil,
      col = nil,
      title = "Codex",
    },
    codex_cmd = { "codex" },
    focus_after_send = false,
    log_level = "warn",
    autostart = false,
  },
}
