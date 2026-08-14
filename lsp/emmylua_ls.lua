---@type vim.lsp.Config
return {
    settings = {
        emmylua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
                ignoreDir = { '.git' },
                library = {
                    vim.env.VIMRUNTIME,
                    ---@diagnostic disable-next-line
                    vim.fs.joinpath(vim.fn.stdpath 'data', 'site', 'pack', 'core', 'opt'),
                },
            },
        },
    },
}
