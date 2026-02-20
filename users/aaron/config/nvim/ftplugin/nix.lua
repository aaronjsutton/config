vim.lsp.config('nil_ls', {
	settings = {
		['nil'] = {
			nix = {
				flake = {
					autoArchive = true
				},
			},
		}
	}
})

vim.lsp.enable('nil_ls')

vim.treesitter.start()
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo[0][0].foldmethod = 'expr'
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
