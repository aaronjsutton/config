vim.treesitter.start()

vim.lsp.config('nil_ls', {
	settings = {
		autoArchive = true
	}
})

vim.lsp.enable('nil_ls')
vim.treesitter.start()
