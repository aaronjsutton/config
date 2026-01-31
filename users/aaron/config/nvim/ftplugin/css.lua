vim.lsp.config('biome', {
	cmd = { 'bun', 'biome', 'lsp-proxy' },
})

vim.lsp.enable('biome')
