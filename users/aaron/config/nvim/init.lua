require'hunk'.setup {
  ui = {
    tree = {
      mode = "nested",
      width = 35,
    },
    layout = "vertical",
  },
}

require 'tokyonight'.setup {
	style = "night",
	transparent = true,
	styles = {
		comments = { italic = true },
		keywords = { italic = false },
	}
}

vim.cmd("syntax off")
vim.cmd("colorscheme tokyonight")

vim.opt.list = false
vim.opt.listchars = {
  extends = "…",
  nbsp = "␣",
  precedes = "…",
  space = "·",
  tab = "» ",
  trail = "·",
}

vim.opt.autochdir = true
vim.opt.autoindent = true  
vim.opt.backup = false
vim.opt.clipboard = "unnamed"
vim.opt.cmdheight = 1
vim.opt.expandtab = false  
vim.opt.laststatus = 3
vim.opt.modeline = true
vim.opt.modelines = 3
vim.opt.mouse = ''
vim.opt.number = true
vim.opt.shiftwidth = 2     
vim.opt.shortmess:append({ S = true, s = true, W = true, A = true, a = true, t = true, I = true })
vim.opt.showcmd = false
vim.opt.showcmd = false  
vim.opt.showmode = false
vim.opt.signcolumn = "number"
vim.opt.smartindent = false
vim.opt.softtabstop = 2
vim.opt.statusline = " %f %m %= %l:%c"
vim.opt.tabstop = 2       
vim.opt.textwidth = 80
vim.opt.writebackup = false

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
vim.keymap.set('n', "[g", vim.diagnostic.goto_prev)
vim.keymap.set('n', 'gd', vim.diagnostic.open_float)
vim.keymap.set('n', 'gK', function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)
vim.keymap.set("v", "<leader>s", ":'<,'>sort<CR>")
vim.keymap.set("n", "<Leader>a", ":set list!<CR>")

vim.diagnostic.config({ 
	virtual_lines = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = ' ⬤',
			[vim.diagnostic.severity.WARN]  = ' ◎',
		}
	}
})

vim.filetype.add {
	[vim.fn.expand("~/.config/ghostty/config")] = "dosini",

	extension = {
		jjdescription = 'jjdescription',
		razor = 'razor',
		cshtml = 'razor',
	},

}
