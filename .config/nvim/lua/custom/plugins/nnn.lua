return {
	"luukvbaal/nnn.nvim",
	config = function()
		require("nnn").setup()
	end,
	keys = {
		-- 👇 in this section, choose your own keymappings!
		{
			"<leader>a",
			"<cmd>NnnExplorer<cr>",
			desc = "Open yazi at the current file",
		},
		-- {
		-- 	-- Open in the current working directory
		-- 	"<leader>cw",
		-- 	"<cmd>Yazi cwd<cr>",
		-- 	desc = "Open the file manager in nvim's working directory",
		a, -- },
		-- {
		-- 	-- NOTE: this requires a version of yazi that includes
		-- 	-- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
		-- 	"<c-up>",
		-- 	"<cmd>Yazi toggle<cr>",
		-- 	desc = "Resume the last yazi session",
		-- },
	},
}
