vim.loader.enable()

vim.pack.add({
  { src = "https://github.com/rktjmp/lush.nvim" },
})

vim.pack.add({
  { src = "https://github.com/zenbones-theme/zenbones.nvim" },
})

vim.pack.add({
	{ 
		src = "https://github.com/nvim-treesitter/nvim-treesitter", 
		version = 'main' 
	},
})

vim.g.neobones = { italic_strings = false, transparent_background = true }

vim.cmd('colorscheme neobones')

require 'settings'
require 'keymaps'
require 'commands'
require 'autocmds'
require 'statusline'
require 'marks'
require 'lsp'

require('vim._core.ui2').enable {}
