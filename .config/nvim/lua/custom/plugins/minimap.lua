return {
	"echasnovski/mini.map",
	version = false,
	config = function()
		local map = require("mini.map")
		map.setup({
			integrations = {
				map.gen_integration.diagnostic(),
			},
		})
		vim.keymap.set("n", "<Leader>mt", MiniMap.toggle)
		vim.api.nvim_create_autocmd("DiagnosticChanged", {
			callback = function(args)
				local diagnostics = args.data.diagnostics
				if #diagnostics > 0 then
					MiniMap.open()
				else
					MiniMap.close()
				end
			end,
		})
	end,
}
