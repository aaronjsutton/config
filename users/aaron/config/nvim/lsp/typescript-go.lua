return {
	-- HACK: Hardcoded path.
  cmd = { '/Users/aaron/Code/as.aaron/typescript-go/built/local/tsgo', '--lsp', '--stdio' },
	filetypes = {
		'javascript',
		'javascriptreact',
		'typescript',
		'typescriptreact',
	},
  root_markers = { 'tsconfig.json', 'package.json', '.git' },
}
