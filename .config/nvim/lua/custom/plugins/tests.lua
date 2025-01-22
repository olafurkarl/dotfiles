return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"marilari88/neotest-vitest",
	},
	config = function()
		local neotest = require("neotest")
		local neoTestVitest = require("neotest-vitest")

		local setup_complete = false

		vim.diagnostic.config({ virtual_text = true })

		local function possibly_init()
			if setup_complete then
				return
			end
			local adapters = {}

			-- Load neotest-jest conditionally
			if vim.bo.filetype == "typescript" or vim.bo.filetype == "typescriptreact" then
				table.insert(adapters, require("neotest-vitest"))
			end

			neotest.setup({
				log_level = vim.log.levels.DEBUG,
				floating = {
					border = "rounded",
					max_height = 100,
					max_width = 100,
					options = {},
				},
				adapters = adapters,
			})
			setup_complete = true
		end
		local function test_nearest()
			possibly_init()
			neotest.run.run({ suite = false })
			neotest.summary.open()
		end

		--
		local function test_all()
			possibly_init()
			neotest.run.run(vim.fn.expand("%"))
			neotest.summary.open()
		end

		local function watch_tests()
			possibly_init()
			neotest.watch.watch({
				suite = false,
			})
			neotest.summary.open()
		end

		local function debug_nearest()
			possibly_init()
			neotest.run.run({ strategy = "dap" })
		end

		vim.keymap.set("n", "<leader>Tr", test_nearest, { desc = "[T]est [r]un" })
		vim.keymap.set("n", "<leader>Tw", watch_tests, { desc = "[T]est [w]atch" })
		vim.keymap.set("n", "<leader>TR", test_all, { desc = "[T]est [R]un all" })
		vim.keymap.set("n", "<leader>Td", debug_nearest, { desc = "[T]est [d]ebug" })
	end,
}
