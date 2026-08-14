local hints = {
    parameterNames = { enabled = 'literals', suppressWhenArgumentMatchesName = true },
    parameterTypes = { enabled = true },
    variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
    propertyDeclarationTypes = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    enumMemberValues = { enabled = true },
}

---@type vim.lsp.Config
return {
    settings = {
        typescript = { inlayHints = hints },
        javascript = { inlayHints = hints },
    },
}
