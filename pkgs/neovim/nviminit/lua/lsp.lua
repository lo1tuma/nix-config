local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = vim.lsp.config
local util = require 'lspconfig.util'

lspconfig.ts_ls = {
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    capabilities = capabilities,
    root_dir = util.root_pattern("package.json", "tsconfig.json"),
    on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end,
}
vim.lsp.enable('ts_ls')

lspconfig.lua_ls  = {
    settings = {
        Lua = {
            format = {
                enable = false,
            },
            telemetry = {
                enable = false,
            },
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
}
vim.lsp.enable('lua_ls')

lspconfig.nil_ls = {}
vim.lsp.enable('nil_ls')

lspconfig.eslint = {
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },

    on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
        })
    end,

    settings = {
        codeAction = {
            disableRuleComment = {
                enable = true,
                location = "separateLine",
            },
            showDocumentation = {
                enable = true,
            },
        },
        codeActionOnSave = {
            enable = false,
            mode = "all",
        },
        experimental = {
            useFlatConfig = false,
        },
        format = true,
        nodePath = "",
        onIgnoredFiles = "off",
        problems = {
            shortenToSingleLine = false,
        },
        quiet = false,
        rulesCustomizations = {},
        run = "onType",
        useESLintClass = false,
        validate = "on",
        workingDirectory = {
            mode = "location",
        },
    },
}
vim.lsp.enable('eslint')

lspconfig.yamlls = {
    capabilities = capabilities,
    settings = {
        yaml = {
            schemaStore = {
                enable = false,
                url = "",
            },
            schemas = require("schemastore").yaml.schemas({
                select = {
                    "gitlab-ci",
                    "GitHub Workflow",
                    "GitHub Action",
                    "docker-compose.yml",
                },
            }),
        },
    },
}
vim.lsp.enable('yamlls')

lspconfig.jsonls = {
    capabilities = capabilities,
    settings = {
        json = {
            schemas = require("schemastore").json.schemas({
                select = {
                    "package.json",
                    "tsconfig.json",
                    ".eslintrc",
                    "Renovate",
                    "prettierrc.json",
                    "Stryker Mutator",
                    "AVA Configuration",
                    "AWS CDK cdk.json",
                    "CSpell (cspell.json)",
                    "jscpd Configuration",
                    "Dependency cruiser",
                    "GitHub Action",
                    "GitHub Workflow",
                    "gitlab-ci",
                },
            }),
            validate = { enable = true },
        },
    },
}
vim.lsp.enable('jsonls')
