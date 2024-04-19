local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require("lspconfig")

lspconfig.tsserver.setup({
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    capabilities = capabilities,
    root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json"),
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end,
})

lspconfig.lua_ls.setup({
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
})

lspconfig.nil_ls.setup({})

lspconfig.eslint.setup({
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
})

lspconfig.yamlls.setup({
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
})

lspconfig.jsonls.setup({
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
                    "gitlab-ci"
                }
            }),
            validate = { enable = true },
        },
    },
})

local none_ls = require("null-ls")

none_ls.setup({
    capabilities = capabilities,
    fallback_severity = vim.diagnostic.severity.HINT,
    sources = {
        none_ls.builtins.code_actions.cspell,
        none_ls.builtins.code_actions.shellcheck,

        none_ls.builtins.diagnostics.cspell.with({
            diagnostic_config = {
                virtual_text = false,
            },
        }),
        none_ls.builtins.diagnostics.shellcheck,

        none_ls.builtins.formatting.prettier.with({
            only_local = "node_modules/.bin",
            filetypes = { "html", "json", "yaml", "markdown", "css" },
            condition = function(utils)
                return utils.root_has_file({
                    ".prettierrc",
                    ".prettierrc.json",
                    ".prettierrc.yml",
                    ".prettierrc.yaml",
                    ".prettierrc.js",
                    "prettier.config.js",
                    ".prettierrc.mjs",
                    "prettier.config.mjs",
                    ".prettierrc.cjs",
                    "prettier.config.cjs",
                    ".prettierrc.toml",
                })
            end,
        }),
        none_ls.builtins.formatting.stylua,
        none_ls.builtins.formatting.shfmt,
    },
    on_attach = function(client, bufnr)
        -- Format files on save
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({
                        bufnr = bufnr,
                        filter = function(client)
                            return client.name == "null-ls"
                        end,
                    })
                end,
            })
        end
    end,
})
