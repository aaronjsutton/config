vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('aaron/treesitter_folding', { clear = true }),
	desc = 'Enable Treesitter folding',
	callback = function(args)
			local bufnr = args.buf

			-- Enable Treesitter folding when not in huge files and when Treesitter
			-- is working.
			if vim.bo[bufnr].filetype ~= 'bigfile' and pcall(vim.treesitter.start, bufnr) then
					vim.api.nvim_buf_call(bufnr, function()
							vim.wo[0][0].foldmethod = 'expr'
							vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
							vim.cmd.normal 'zx'
					end)
			end
	end,
})
