local lint = require("lint")

local cspellNamespace = lint.get_namespace("cspell")

vim.diagnostic.config({ virtual_text = false }, cspellNamespace)

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    callback = function()
        lint.try_lint("cspell")
    end,
})
