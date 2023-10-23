local whichKey = require("which-key")

whichKey.setup({
    plugins = {
        marks = false, -- shows a list of your marks on ' and `
        registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = {
            enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20, -- how many suggestions should be shown in the list?
        },
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
            operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
            motions = true, -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = true, -- bindings for folds, spelling and others prefixed with z
            g = true, -- bindings for prefixed with g
        },
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    operators = { gc = "Comments" },
    key_labels = {
        -- override the label used to display some keys. It doesn't effect WK in any other way.
        -- For example:
        -- ["<space>"] = "SPC",
        -- ["<cr>"] = "RET",
        -- ["<tab>"] = "TAB",
    },
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
    },
    popup_mappings = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>", -- binding to scroll up inside the popup
    },
    window = {
        border = "none", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
        winblend = 0,
    },
    layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = "left", -- align columns left, center or right
    },
    ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true, -- show help message on the command line when the popup is visible
    triggers = "auto", -- automatically setup triggers
    -- triggers = {"<leader>"} -- or specify a list manually
    triggers_blacklist = {
        -- list of mode / prefixes that should never be hooked by WhichKey
        -- this is mostly relevant for key maps that start with a native binding
        -- most people should not need to change this
        i = { "j", "k" },
        v = { "j", "k" },
    },
})

local telescope = require("telescope.builtin")

whichKey.register({
    h = {
        name = "Git Hunk",
        p = { "Preview" },
        s = { "Stage" },
        u = { "Undo / Revert" },
    },
    f = {
        name = "Find",
        f = { telescope.find_files, "Find File (by name)" },
        g = { telescope.live_grep, "Find File (by content)" },
        b = { telescope.buffers, "Open Buffers" },
        r = { telescope.oldfiles, "Open Recent File" },
        h = { telescope.help_tags, "Open Help Entries" },
    },
    l = {
        name = "LSP",
        d = {
            function()
                telescope.diagnostics()
            end,
            "File Diagnostics",
        },
        a = {
            function()
                vim.lsp.buf.code_action()
            end,
            "Code Action",
        },
        h = {
            function()
                vim.lsp.buf.hover()
            end,
            "Hover",
        },
        f = {
            function()
                vim.lsp.buf.format()
            end,
            "Format",
        },
        r = {
            function()
                vim.lsp.buf.references()
            end,
            "references",
        },
        R = {
            function()
                vim.lsp.buf.rename()
            end,
            "Rename",
        },
        s = {
            function()
                vim.lsp.buf.signature_help()
            end,
            "Singnature help",
        },
        c = {
            function()
                vim.lsp.buf.definition()
            end,
            "Code Definition",
        },
        t = {
            function()
                vim.lsp.buf.type_definition()
            end,
            "Type Definition",
        },
        D = {
            function()
                vim.lsp.buf.declaration()
            end,
            "Declaration",
        },
        i = {
            function()
                vim.lsp.buf.implementation()
            end,
            "Implementation",
        },
        q = {
            function()
                vim.diagnostic.setloclist()
            end,
            "Quickfix",
        },
    },
}, { prefix = "<leader>" })
