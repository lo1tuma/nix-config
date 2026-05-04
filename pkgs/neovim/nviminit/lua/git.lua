require("gitsigns").setup({
    signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
    },
    signcolumn = true,
    current_line_blame = false,
})

vim.keymap.set("n", "]h", function()
    require("gitsigns").nav_hunk("next")
end, { silent = true, desc = "Next Git hunk" })

vim.keymap.set("n", "[h", function()
    require("gitsigns").nav_hunk("prev")
end, { silent = true, desc = "Previous Git hunk" })
