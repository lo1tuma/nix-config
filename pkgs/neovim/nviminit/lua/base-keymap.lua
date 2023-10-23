-- unset search term
vim.keymap.set('n', '<space>', function() vim.fn.setreg('/', '') end, { silent = true })
