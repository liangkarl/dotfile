local keymaps = require("config.keymaps")

return {
	'kevinhwang91/nvim-ufo',
  dependencies = {
		'kevinhwang91/promise-async',
  },
	lazy = false,
	keys = keymaps.ufo_keys,
	opts = {}, -- needed even when using default config

	-- recommended: disable vim's auto-folding
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
		vim.opt.foldenable = false
	end,

	config = function ()

		local ufo = require('ufo')

		-- Option 3: treesitter as a main provider instead
		-- (Note: the `nvim-treesitter` plugin is *not* needed.)
		-- ufo uses the same query files for folding (queries/<lang>/folds.scm)
		-- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
		ufo.setup({
			provider_selector = function(bufnr, filetype, buftype)
				-- Try LSP first
				if next(vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/foldingRange" })) then
					return { 'lsp', 'indent' }
				end
				-- Fallback to Treesitter
				local lang = vim.treesitter.language.get_lang(filetype)
				local has_parser, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
				if buftype == "" and has_parser and parser then
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
