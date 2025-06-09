return {
	"mistweaverco/kulala.nvim",
	opts = {},

	config = function()
		-- require("kulala.api").on("after_request", function(data)
		--
		-- end)

		vim.keymap.set("n", "<Leader>rr", function()
			require("kulala").run()
		end, { desc = "[r]un [r]est command" })

		vim.keymap.set("n", "<Leader>rl", function()
			require("kulala").inspect()
		end, { desc = "[r]est: [i]nspect the current request" })
		vim.keymap.set("n", "]", function()
			require("kulala").jump_next()
		end, { desc = "Jump to next rest request" })
		vim.keymap.set("n", "[", function()
			require("kulala").jump_prev()
		end, { desc = "Jump to previous rest request" })

		vim.keymap.set("n", "<Leader>rc", function()
			require("kulala").copy()
		end, { desc = "[r]est: [c]opy as curl" })
	end,
	ft = { "http" },
}
