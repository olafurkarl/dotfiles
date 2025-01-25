return {
	"rmagatti/auto-session",
	enabled = true,
	config = function()
		require("auto-session").setup({
			log_level = "error",
			auto_session_suppress_dirs = { "~/", "~/projects", "~/Downloads", "/" },
			pre_save_cmds = { "tabdo Neotree close" },
			-- post_restore_cmds = { "Neotree" },
		})
	end,
}
