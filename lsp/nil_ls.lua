---@type vim.lsp.Config
return {
    settings = {
        ['nil'] = {
            formatting = { command = { 'alejandra', '--quiet' } },
        },
    },
}
