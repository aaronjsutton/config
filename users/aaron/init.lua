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

vim.opt.signcolumn = "number"
vim.g.mapleader = ','

vim.opt.modelines = 2
vim.opt.showmode = true
vim.opt.showcmd = false
vim.opt.cmdheight = 1
vim.opt.shortmess:append({ S = true, s = true, W = true, A = true, a = true, t = true, I = true })

vim.o.foldcolumn = '0'
vim.o.foldlevel = 4
vim.o.foldlevelstart = 4
vim.o.foldenable = true

vim.keymap.set('', '<Up>', '<Nop>', { noremap = true })
vim.keymap.set('', '<Left>', '<Nop>', { noremap = true })
vim.keymap.set('', '<Right>', '<Nop>', { noremap = true })
vim.keymap.set('', '<Down>', '<Nop>', { noremap = true })

vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float)

-- Currently has a massive memory consumption problem.
-- vim.lsp.enable('typescript-go')
vim.lsp.enable('nil_ls')
vim.lsp.enable('ts_ls')

require'nvim-treesitter.configs'.setup {
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},

	indent = {
		enable = true
	},
}

vim.cmd [[hi LspInlayHint guibg=none]]
