---@brief
---
--- Experimental support for typescript-go.
return {
	-- HACK: Hardcoded path.
  cmd = { '/Users/aaron/Code/as.aaron/typescript-go/built/local/tsgo', '--lsp', '--stdio' },
	filetypes = {
		'javascript',
		'javascriptreact',
		'javascript.jsx',
		'typescript',
		'typescriptreact',
		'typescript.tsx',
	},
  root_markers = { 'tsconfig.json', 'package.json', '.git' },
}
