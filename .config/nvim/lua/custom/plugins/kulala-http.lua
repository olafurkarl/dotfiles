return {
	"mistweaverco/kulala.nvim",
	opts = {},

	config = function()
		vim.keymap.set("n", "<Leader>rr", function()
			require("kulala").run()
		end, { desc = "[r]un [r]est command" })
	end,
}
