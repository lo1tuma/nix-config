require("nvim-treesitter").setup({})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "bash",
        "c",
        "diff",
        "gitcommit",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "nix",
        "query",
        "tmux",
        "toml",
        "typescript",
        "vim",
        "yaml",
    },
    callback = function()
        vim.treesitter.start()
    end,
})
