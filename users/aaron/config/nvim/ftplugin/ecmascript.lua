vim.lsp.config('biome', {
	cmd = { 'bun', '--bun', 'biome', 'lsp-proxy' },
})

vim.lsp.enable('biome')
vim.lsp.enable('tsgo')

vim.treesitter.start()
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo[0][0].foldmethod = 'expr'
