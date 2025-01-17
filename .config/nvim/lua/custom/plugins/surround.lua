return {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		local ts_input = require("mini.surround").gen_spec.input.treesitter
		require("mini.surround").setup({
			custom_surroundings = {
				-- Use tree-sitter to search for function call
				f = {
					input = ts_input({ outer = "@call.outer", inner = "@call.inner" }),
				},
			},
		})
		-- vim.keymap.set("n", '<leader>"',)
	end,
}
