return {
	"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	enabled = false,
	config = function()
		require("lsp_lines").setup()
		local virtual_lines_enabled = true

		vim.diagnostic.config({
			virtual_lines = virtual_lines_enabled,
			virtual_text = not virtual_lines_enabled,
		})
		vim.keymap.set("n", "<leader>lt", "Toggle lsp_lines", {
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
