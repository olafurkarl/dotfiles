return {
	{
		"rest-nvim/rest.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			opts = function(_, opts)
				opts.ensure_installed = opts.ensure_installed or {}
				table.insert(opts.ensure_installed, "http")
			end,
		},
		config = function()
			vim.keymap.set("n", "<Leader>rr", ":hor Rest run<CR>", { desc = "[r]un [r]est command" })
			vim.keymap.set("n", "<Leader>re", function()
				-- first load extension
				require("telescope").load_extension("rest")
				-- then use it, you can also use the `:Telescope rest select_env` command
				require("telescope").extensions.rest.select_env()
			end, { desc = "Select [r]est [e]nvironment" })
		end,
	},
}
