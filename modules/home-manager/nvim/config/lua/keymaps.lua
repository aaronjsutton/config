-- Disable arrow keys.
vim.keymap.set('', '<Up>', '<Nop>', { noremap = true })
vim.keymap.set('', '<Left>', '<Nop>', { noremap = true })
vim.keymap.set('', '<Right>', '<Nop>', { noremap = true })
vim.keymap.set('', '<Down>', '<Nop>', { noremap = true })

-- Diagnostics.
vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set('n', "[g", vim.diagnostic.goto_prev)
vim.keymap.set('n', 'gd', vim.diagnostic.open_float)
vim.keymap.set('n', 'gK', function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)

-- Formatting.
vim.keymap.set('n', 'gF', ':silent !jj fix<CR>')

vim.keymap.set("v", "<leader>s", ":'<,'>sort<CR>")
vim.keymap.set("n", "<leader>L", function()
  vim.opt.list = not vim.opt.list:get()
end, { noremap = true, silent = true })
