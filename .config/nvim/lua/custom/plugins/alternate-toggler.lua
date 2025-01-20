return {
	"rmagatti/alternate-toggler",
	config = function()
		require("alternate-toggler").setup({
			alternates = {
				["=="] = "!=",
				["false"] = "true",
			},
		})

		vim.keymap.set(
			"n",
			"<C-s>", -- <space><space>
			"<cmd>lua require('alternate-toggler').toggleAlternate()<CR>"
		)
	end,
}
