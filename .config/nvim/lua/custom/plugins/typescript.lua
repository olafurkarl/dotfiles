return {
	"pmizio/typescript-tools.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	expose_as_code_action = "all",
	opts = {
		on_attach = function(client, bufnr)
      -- stylua: ignore
      if client.server_capabilities.inlayHintProvider then vim.lsp.inlay_hint.enable(true) end
      -- stylua: ignore
      local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = bufnr }) end
			map("n", "<Leader>ci", "<Cmd>TSToolsAddMissingImports<CR>", "Add Missing Imports")
			map("n", "<Leader>co", "<Cmd>TSToolsOrganizeImports<CR>", "Organize Imports")
			map("n", "<Leader>cR", "<Cmd>TSToolsFileReferences<CR>", "File References")
			map("n", "<Leader>cri", "<Cmd>TSToolsRemoveUnusedImports<CR>", "Remove Unused Imports")
		end,
	},
}
