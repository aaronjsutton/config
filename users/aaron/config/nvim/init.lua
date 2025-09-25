vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.modeline = true
vim.opt.laststatus = 3
vim.opt.statusline = " %f %m %= %l:%c"

require("kanagawa-paper").setup({
	cache = true,
	transparent = true,
	undercurl = true,            
	overrides = function(colors)
		return {
			["@variable.builtin"]  = {
				bold = true,
				italic = false
			},
		}
	end,
})

vim.cmd("colorscheme kanagawa-paper")

vim.opt.list = false
vim.opt.listchars = {
  tab = "»·",
  trail = "·",
  space = "·",
  extends = "…",
  precedes = "…",
  nbsp = "␣",
}

vim.opt.mouse = ''
vim.opt.number = true

vim.opt.expandtab = false  
vim.opt.showcmd = false  
vim.opt.autochdir = true

vim.opt.autoindent = true  
vim.opt.shiftwidth = 2     
vim.opt.tabstop = 2       
vim.opt.softtabstop = 2
vim.opt.textwidth = 80

vim.opt.modelines = 3
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.cmdheight = 1
vim.opt.shortmess:append({ S = true, s = true, W = true, A = true, a = true, t = true, I = true })
vim.opt.signcolumn = "number"

vim.o.foldcolumn = '0'
vim.o.foldlevel = 4
vim.o.foldlevelstart = 4
vim.o.foldenable = true

vim.g.mapleader = ','

vim.keymap.set('', '<Up>', '<Nop>', { noremap = true })
vim.keymap.set('', '<Left>', '<Nop>', { noremap = true })
vim.keymap.set('', '<Right>', '<Nop>', { noremap = true })
vim.keymap.set('', '<Down>', '<Nop>', { noremap = true })
vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float)
vim.keymap.set("v", "<leader>s", ":'<,'>sort<CR>")
vim.keymap.set("n", "<Leader>L", ":set list!<CR>")

require'nvim-treesitter.configs'.setup {
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},

	indent = {
		enable = true
	},
}

vim.diagnostic.config({ 
	virtual_lines = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = ' ⬤',
			[vim.diagnostic.severity.WARN]  = ' ◎',
		}
	}
})

vim.lsp.config('biome', {
	cmd = { 'bunx', '--bun', 'biome', 'lsp-proxy' },
})

vim.lsp.enable('typescript-go')
vim.lsp.enable('tofu_ls')
vim.lsp.enable('biome')
vim.lsp.enable('nil_ls')
vim.lsp.enable('csharp_ls')
