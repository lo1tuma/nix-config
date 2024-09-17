local whichKey = require("which-key")

whichKey.setup({
    preset = "modern",
    delay = function(ctx)
        return ctx.plugin and 0 or 500
    end,
    filter = function(mapping)
      return true
      end,
      spec = {},
      notify = true,
      defer = function(ctx)
    return ctx.mode == "V" or ctx.mode == "<C-V>"
  end,
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
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
    },
    triggers = {
        { "<auto>", mode = "nixsotc" },
    },
    layout = {
        width = { min = 20 },
        spacing = 3, -- spacing between columns
    },
    keys = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>", -- binding to scroll up inside the popup
      },
      sort = { "local", "order", "group", "alphanum", "mod" },
      expand = 0, -- expand groups when <= n mappings
    show_help = true, -- show help message on the command line when the popup is visible
    show_keys = true,
    debug = false
})

local telescope = require("telescope.builtin")

whichKey.add({
    { "<leader>f", group = "Find" },
    { "<leader>fb", telescope.buffers, desc = "Open Buffers" },
    { "<leader>ff", telescope.find_files, desc = "Find File (by name)" },
    { "<leader>fg", telescope.live_grep, desc = "Find File (by content)" },
    { "<leader>fh", telescope.help_tags, desc = "Open Help Entries" },
    { "<leader>fr", telescope.oldfiles, desc = "Open Recent File" },
    { "<leader>h", group = "Git Hunk" },
    { "<leader>hp", desc = "Preview" },
    { "<leader>hs", desc = "Stage" },
    { "<leader>hu", desc = "Undo / Revert" },
    { "<leader>l", group = "LSP" },
    {
        "<leader>lD",
        function()
            vim.lsp.buf.declaration()
        end,
        desc = "Declaration",
    },
    {
        "<leader>lR",
        function()
            vim.lsp.buf.rename()
        end,
        desc = "Rename",
    },
    {
        "<leader>la",
        function()
            vim.lsp.buf.code_action()
        end,
        desc = "Code Action",
    },
    {
        "<leader>lc",
        function()
            vim.lsp.buf.definition()
        end,
        desc = "Code Definition",
    },
    {
        "<leader>ld",
        function()
            telescope.diagnostics()
        end,
        desc = "File Diagnostics",
    },
    {
        "<leader>lf",
        function()
            vim.lsp.buf.format()
        end,
        desc = "Format",
    },
    {
        "<leader>lh",
        function()
            vim.lsp.buf.hover()
        end,
        desc = "Hover",
    },
    {
        "<leader>li",
        function()
            vim.lsp.buf.implementation()
        end,
        desc = "Implementation",
    },
    {
        "<leader>lq",
        function()
            vim.diagnostic.setloclist()
        end,
        desc = "Quickfix",
    },
    {
        "<leader>lr",
        function()
            vim.lsp.buf.references()
        end,
        desc = "references",
    },
    {
        "<leader>ls",
        function()
            vim.lsp.buf.signature_help()
        end,
        desc = "Singnature help",
    },
    {
        "<leader>lt",
        function()
            vim.lsp.buf.type_definition()
        end,
        desc = "Type Definition",
    },
})
