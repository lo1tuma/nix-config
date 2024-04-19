require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "dprint", "prettier" },
        json = { "dprint", "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        toml = { "dprint" },
        nix = { "nixfmt" },
        sh = { "shfmt" },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },
})
