return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-jest",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-jest")({
						jestCommand = "pnpm test --",
						-- jestConfigFile = "custom.jest.config.ts",
						env = { CI = true },
						cwd = function(path)
							return vim.fn.getcwd()
						end,
					}),
				},
			})
			local neotest = require("neotest")
			vim.keymap.set("n", "<leader>Ts", neotest.summary(), { desc = "[T]est [s]ummary" })
			-- vim.keymap.set('n', '<leader>td', require('neotest').run.run { strategy = 'dap' })
		end,
		keys = {
			{
				"<leader>TR",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Run All",
			},
			{
				"<leader>Tr",
				function()
					require("neotest").run.run()
				end,
				desc = "Run Nearest",
			},
			{
				"<leader>Td",
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "Debug Nearest",
			},
		},
	},
}
