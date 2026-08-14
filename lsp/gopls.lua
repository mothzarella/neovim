---@type vim.lsp.Config
return {
    settings = {
        gopls = {
            semanticTokens = false,
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
            analyses = {
                unusedparams = true,
                unusedwrite = true,
                useany = true,
                nilness = true,
                shadow = false,
            },
            staticcheck = true,
            usePlaceholders = false,
            gofumpt = true,
        },
    },
}
