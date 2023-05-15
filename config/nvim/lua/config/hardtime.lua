-- Plugin: hardtime.nvim
-- https://github.com/m4xshen/hardtime.nvim

-- Talking about bad habbits in vim
-- http://vimcasts.org/blog/2013/02/habit-breaking-habit-making/

-- 1. Don’t use arrow keys and mouse.
-- 2. Use relative jump (eg: 5k 12j) for vertical movement inside screen.
-- 3. Use CTRL-U CTRL-D CTRL-B CTRL-F gg G for vertical movement outside screen.
-- 4. Use word-motion (w W b B e E ge gE) for short distance horizontal movement.
-- 5. Use f F t T 0 ^ $ , ; for mid long distance horizontal movement.
-- 6. Use operator + motion/text-object (eg: ci{ d5j) whenever possible.
require('hardtime').setup({
  max_count = 4,
  max_time = 300,
  -- check filetype with `echo &filetype`
  disabled_filetypes = {
      "help", "man", "qf",
      "NvimTree", "aerial", "startify", "mason" },
})
