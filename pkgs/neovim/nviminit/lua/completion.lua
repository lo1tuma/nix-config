local cmp = require("cmp")

cmp.setup({
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "nvim_lsp_document_symbol" },
        { name = "buffer" },
        { name = "path" },
        { name = "emoji" },
    }, {
        { name = "buffer" },
    }),
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    }),
})
