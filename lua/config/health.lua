return {
    check = function()
        vim.health.start 'config'

        if vim.fn.has 'nvim-0.12' == 1 then
            vim.health.ok(('Neovim %s'):format(tostring(vim.version()))) ---@diagnostic disable-line
        else
            vim.health.error 'Neovim 0.12+ required'
        end

        for exe, why in pairs {
            git = 'vim.pack.add clones plugins with git',
            fzf = 'fzf-lua drives the `fzf` binary',
            rg = 'fzf-lua grep providers',
        } do
            if vim.fn.executable(exe) == 1 then
                vim.health.ok(('`%s` (%s)'):format(exe, why))
            else
                vim.health.error(('`%s` not found on PATH: %s'):format(exe, why))
            end
        end

        for exe, langs in pairs {
            stylua = 'lua',
            alejandra = 'nix',
            ruff = 'python',
            oxfmt = 'javascript/typescript',
        } do
            if vim.fn.executable(exe) == 1 then
                vim.health.ok(('`%s` (%s)'):format(exe, langs))
            else
                vim.health.warn(("`%s` not found: `<leader>fm` won't work for %s"):format(exe, langs))
            end
        end

        for _, exe in ipairs {
            'emmylua_ls',
            'gopls',
            'nil',
            'oxlint',
            'ruff',
            'tailwindcss-language-server',
            'tsgo',
            'ty',
        } do
            if vim.fn.executable(exe) == 1 then
                vim.health.ok(('`%s`'):format(exe))
            else
                vim.health.warn(('`%s` not found: run `:MasonInstallAll`'):format(exe))
            end
        end
    end,
}
