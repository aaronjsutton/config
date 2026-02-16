vim.treesitter.start()
vim.lsp.config('biome', {
	cmd = { 'bun', '--bun', 'biome', 'lsp-proxy' },
})
vim.lsp.enable('biome')
