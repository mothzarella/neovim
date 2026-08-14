---@type vim.lsp.Config
return {
    on_attach = function(client) client.server_capabilities.hoverProvider = nil end,
    init_options = {
        settings = {
            organizeImports = true,
            fixAll = true,
            codeAction = { fixViolation = { enable = true } },
        },
    },
}
