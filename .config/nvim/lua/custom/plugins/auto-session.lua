return {
	"rmagatti/auto-session",
	enabled = true,
	config = function()
		require("auto-session").setup({
			log_level = "error",
			auto_save_enabled = true,
			auto_restore_enabled = true,
			auto_session_suppress_dirs = { "~/", "~/projects", "~/Downloads", "/" },
			bypass_session_save_file_types = { "neo-tree" },
		})

		vim.api.nvim_create_autocmd("BufWritePost", {
			callback = function()
				require("auto-session").save_session()
			end,
		})
	end,
}
