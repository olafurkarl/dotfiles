_G.LazygitEditFile = function(tmpfile)
	local lines = {}
	for line in io.lines(tmpfile) do
		table.insert(lines, line)
	end
	os.remove(tmpfile)

	local filename = lines[1]
	local line_num = tonumber(lines[2])

	-- Find the first non-floating window to open the file in
	local target_win = nil
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(w).relative == "" then
			target_win = w
			break
		end
	end

	-- Close all floating windows (lazygit float)
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(w).relative ~= "" then
			vim.api.nvim_win_close(w, true)
		end
	end

	if target_win then
		vim.api.nvim_set_current_win(target_win)
	end
	vim.cmd("edit " .. vim.fn.fnameescape(filename))
	if line_num then
		vim.api.nvim_win_set_cursor(0, { line_num, 0 })
	end
end

return {
	"kdheepak/lazygit.nvim",
	lazy = true,
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	-- optional for floating window border decoration
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	-- setting the keybinding for LazyGit with 'keys' is recommended in
	-- order to load the plugin when the command is run for the first time
	keys = {
		{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
	},
}
