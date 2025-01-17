return {
	"kevinhwang91/nvim-ufo",

	dependencies = { "kevinhwang91/promise-async" },
	--    event = 'VeryLazy',   -- You can make it lazy-loaded via VeryLazy, but comment out if thing doesn't work
	init = function()
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.keymap.set("n", "zR", require("ufo").openAllFolds)
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
	end,
	config = function()
		require("ufo").setup({
			provider_selector = function(bufnr, filetype, buftype)
				return { "treesitter", "indent" }
			end,
		})
	end,
}
