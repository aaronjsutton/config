vim.lsp.config('biome', {
	cmd = { 'bunx', '--bun', 'biome', 'lsp-proxy' },
})

vim.lsp.enable('biome')
