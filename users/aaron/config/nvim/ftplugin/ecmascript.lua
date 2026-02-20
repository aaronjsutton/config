vim.lsp.config('biome', {
	cmd = { 'bun', '--bun', 'biome', 'lsp-proxy' },
})

vim.lsp.enable('biome')
vim.lsp.enable('typescript-go')

vim.treesitter.start()
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo[0][0].foldmethod = 'expr'
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

