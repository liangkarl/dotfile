-- Plugin: auto-pairs
-- https://github.com/jiangmiao/auto-pairs
-- https://github.com/Krasjet/auto.pairs

-- Avoid conflict with edit motion"
return { -- enhance [/{/'..., auto balance pairs
  'Krasjet/auto.pairs',
  config = function()
    vim.g.AutoPairsShortcutBackInsert = '<M-B>'
  end
}
