return {
	'kevinhwang91/nvim-ufo',
  dependencies = {
		'kevinhwang91/promise-async',
  },
	opts = {}, -- needed even when using default config

	-- recommended: disable vim's auto-folding
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
		vim.opt.foldenable = false
	end,

	config = function ()
		local util = require('core.utils')

		-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
		vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
		vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
		vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
		vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith)
		vim.keymap.set('n', 'zp', require('ufo').peekFoldedLinesUnderCursor)

		-- Option 3: treesitter as a main provider instead
		-- (Note: the `nvim-treesitter` plugin is *not* needed.)
		-- ufo uses the same query files for folding (queries/<lang>/folds.scm)
		-- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
		require('ufo').setup({
			provider_selector = function(bufnr, filetype, buftype)
				-- Try LSP first
				if util.has_lsp(bufnr, filetype, buftype) then
					return { 'lsp', 'indent' }
				end
				-- Fallback to Treesitter
				if util.has_treesitter(bufnr, filetype, buftype) then
					return { 'treesitter', 'indent' }
				end
				-- Fallback to indent if neither LSP nor Treesitter are available
				return 'indent'
			end,
			preview = {
				win_config = {
					winblend = 0,
				}
			}
		})
		--
	end,
}
