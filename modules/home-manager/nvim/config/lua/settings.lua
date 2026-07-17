local arrows = require('icons').arrows

-- Leader.
vim.g.mapleader = ','

-- Use an indentation of 2 spaces.
vim.o.sw = 2
vim.o.ts = 2
vim.o.sts = 2
vim.o.et = true

vim.g.loaded_node_provider = 0;
vim.g.loaded_perl_provider = 0;
vim.g.loaded_python3_provider = 0;
vim.g.loaded_ruby_provider = 0;

vim.wo.number = true


vim.opt.autochdir = true

-- Show whitespace.
vim.opt.list = true
vim.opt.listchars = { space = '⋅', trail = '⋅', tab = '  ↦' }

-- Wrap long lines at words.
vim.o.linebreak = true

-- Folding.
vim.o.foldcolumn = '1'
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.wo.foldtext = ''

-- UI characters.
vim.opt.fillchars = {
    eob = ' ',
    fold = ' ',
    foldclose = arrows.right,
    foldopen = arrows.down,
    foldsep = ' ',
    foldinner = ' ',
    msgsep = '─',
}

vim.opt.shortmess:append {
    w = true,
    s = true,
}

-- Status line.
vim.o.laststatus = 3
vim.o.cmdheight = 1

-- Use rounded borders for floating windows.
vim.o.winborder = 'rounded'

-- Sync clipboard between the OS and Neovim.
vim.o.clipboard = 'unnamedplus'
