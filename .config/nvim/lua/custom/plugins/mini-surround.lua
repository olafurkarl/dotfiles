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
			mappings = {
				add = "sa", -- Add surrounding in Normal and Visual modes
				delete = "sd", -- Delete surrounding
				find = "sf", -- Find surrounding (to the right)
				find_left = "sF", -- Find surrounding (to the left)
				highlight = "sh", -- Highlight surrounding
				replace = "sr", -- Replace surrounding
				kpdate_n_lines = "sn", -- Update `n_lines`

				suffix_last = "l", -- Suffix to search with "prev" method
				suffix_next = "n", -- Suffix to search with "next" method
			},
		})
		-- vim.keymap.set("n", '<leader>"',)
	end,
}
