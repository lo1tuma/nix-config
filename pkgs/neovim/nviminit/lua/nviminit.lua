require("base-keymap")

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- colors & theme
vim.opt.termguicolors = true
vim.cmd([[colorscheme catppuccin-mocha]])

-- files
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = "ucs-bom,utf8,prc"
vim.opt.swapfile = false

-- mouse
vim.opt.mouse = ""
vim.opt.mousescroll = "ver:0,hor:0"

-- cursor
vim.opt.ruler = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = true

-- visual max-line width indicator
vim.opt.colorcolumn = "120"

-- indentation
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.autoindent = true

-- splitting
vim.opt.splitbelow = true
vim.opt.splitright = true

-- search
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- navigation
vim.opt.scrolloff = 5

-- text
vim.opt.list = true
vim.opt.listchars = "nbsp:␠,tab:→ ,trail:·,precedes:⇐,extends:⇒"
vim.opt.guifont = "Monaco:h11"
vim.opt.guifontwide = "NSimsun:h12"
vim.opt.foldenable = false
vim.opt.conceallevel = 1

-- diagnostics
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300
vim.opt.laststatus = 2
vim.diagnostic.config({
    virtual_text = {
        source = true,
    },
    float = {
        source = true,
    },
})

-- completion
vim.opt.completeopt = "menu,menuone,preview,noinsert,noselect"

-- info
vim.opt.showcmd = true
vim.opt.statusline:append("%=%f") -- show file path at the end of statusline

-- GUI elements
vim.opt.cmdheight = 1
vim.opt.pumblend = 13

-- Error bells
vim.opt.errorbells = false
vim.opt.visualbell = true

-- plugin settings
require("telescope-settings")
require("help")
require("lsp")
require("completion")
require("syntax")
require("linter")
require("formatter")
require("nvim-surround").setup({})
