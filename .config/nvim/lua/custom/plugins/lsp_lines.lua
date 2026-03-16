return {
	"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	enabled = true,
	config = function()
		require("lsp_lines").setup()
		local virtual_lines_enabled = false

		vim.diagnostic.config({
			virtual_lines = virtual_lines_enabled,
			virtual_text = not virtual_lines_enabled,
		})
		vim.keymap.set("n", "<leader>tl", "[t]oggle [l]sp_lines", {
			callback = function()
				virtual_lines_enabled = not virtual_lines_enabled
				vim.diagnostic.config({
					virtual_lines = virtual_lines_enabled,
					virtual_text = not virtual_lines_enabled,
				})
			end,
		})
	end,
}
