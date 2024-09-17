require("telescope").setup({
    defaults = {
        path_display = {
            "filename_first",
            "smart",
        },
        file_ignore_patterns = { ".git/" },
        mappings = {
            i = {
                ["<C-h>"] = "which_key",
            },
        },
    },
    pickers = {
        find_files = {
            find_command = { "fd", "--type", "file", "--hidden" },
        },
        live_grep = {
            additional_args = { "--ignore-case", "--hidden" },
        },
    },
})
