vim.loader.enable()

local group = vim.api.nvim_create_augroup('init', { clear = true })

-- Helpers ---------------------------------------------------------------------

---@param delay integer
---@param fn function
---@return fun(override?: integer)
local function debounce(delay, fn)
    local timer = assert(vim.uv.new_timer())
    local wrapped = vim.schedule_wrap(fn)

    return function(override)
        timer:stop()
        timer:start(override or delay, 0, wrapped)
    end
end

local async ---@type fun(fn: async fun())
local await ---@type fun(argc: integer, fun: function, ...: any): any ...
local safe ---@type fun(spec: string, fn: function): any

-- Async/Await
do
    local co = coroutine

    ---@param thread thread
    ---@param ... any
    local function step(thread, ...)
        local ok, thunk = co.resume(thread, ...)
        if not ok then
            vim.notify(debug.traceback(thread, thunk), vim.log.levels.WARN)
        elseif co.status(thread) ~= 'dead' then
            thunk(function(...) step(thread, ...) end)
        end
    end

    ---@param fn async fun()
    function async(fn) step(co.create(fn)) end

    ---@async
    ---@param argc integer
    ---@param fun function
    ---@param ... any
    ---@return any ...
    function await(argc, fun, ...)
        local args = { n = select('#', ...), ... }
        return co.yield(function(callback)
            args[argc] = callback
            fun(unpack(args, 1, math.max(argc, args.n)))
        end)
    end
end

-- Safe context
do
    local kinds, queue = {}, {} ---@type table<string, fun(arg: string?, fn: function)>, fun()[]?

    ---@param spread boolean Yield between entries instead of running them in one block.
    local function drain(spread)
        local pending = queue
        if not pending then return end
        queue = nil

        local i = 0
        local function run()
            i = i + 1
            local fn = pending[i]
            if not fn then return end

            local ok, err = pcall(fn)
            if not ok then vim.notify(tostring(err), vim.log.levels.WARN) end

            if not spread then return run() end
            vim.schedule(run)
        end
        run()
    end

    vim.api.nvim_create_autocmd('SafeState', {
        group = group,
        once = true,
        nested = true,
        callback = function() drain(true) end,
    })

    vim.api.nvim_create_autocmd('VimEnter', {
        group = group,
        once = true,
        nested = true,
        callback = function()
            if vim.list_contains(vim.v.argv, '--headless') then drain(false) end
        end,
    })

    ---@param _ string?
    ---@param fn fun()
    function kinds.later(_, fn)
        if not queue then return fn() end
        queue[#queue + 1] = fn
    end

    ---@param arg string `<Event>[,<Event>...][~<pattern>[,<pattern>...]]`;
    ---@param fn async fun()
    function kinds.event(arg, fn)
        local ev, pat = assert(arg:match '^([^~]+)~?(.*)$')
        local evs = vim.split(ev, ',') ---@cast evs vim.api.keyset.events[]
        vim.api.nvim_create_autocmd(evs, {
            group = group,
            pattern = pat ~= '' and vim.split(assert(pat), ',') or nil,
            once = true,
            nested = true,
            callback = function() async(fn) end,
        })
    end

    ---@param arg string `<Cmd>[,<Cmd>...]`;
    ---@param fn async fun()
    function kinds.cmd(arg, fn)
        local names = vim.split(arg, ',')

        for _, cmd_name in ipairs(names) do
            vim.api.nvim_create_user_command(cmd_name, function(cmd)
                async(function()
                    for _, stub in ipairs(names) do
                        pcall(vim.api.nvim_del_user_command, stub)
                    end
                    fn()
                    vim.cmd {
                        cmd = cmd_name,
                        args = cmd.fargs,
                        bang = cmd.bang,
                        mods = cmd.smods,
                        range = cmd.range > 0 and { cmd.line1, cmd.line2 } or nil,
                    }
                end)
            end, { bang = true, nargs = '*', range = true, complete = 'file' })
        end
    end

    ---@param _ string?
    ---@param fn function
    ---@return function
    function kinds.once(_, fn)
        local done = false
        return function(...)
            if done then return end
            local out = fn(...)
            done = true
            return out
        end
    end

    ---@param spec 'later'|string `later`, `event:<Event>,...[~<pattern>]`, or `cmd:<Cmd>,...`.
    ---@param fn async fun()
    ---@return any
    function safe(spec, fn)
        local kind, arg = spec:match '^([^:]+):(.+)$'
        kind = kind or spec

        local handler = kinds[kind]
        if not handler then error('safe: unknown kind ' .. kind) end
        assert(kind == 'later' or kind == 'once' or arg, 'safe: ' .. kind .. ' needs <kind>:<arg>')

        return handler(arg, fn)
    end
end

-- Options ---------------------------------------------------------------------

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.swatch = '󱓻 '
vim.g.border = 'solid'

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.o.confirm = true

vim.o.loadplugins = false -- Skip plugins under $VIMRUNTIME/plugin and 'packpath'

vim.o.shortmess = vim.o.shortmess .. 'IAa' -- Hide the startup screen
vim.o.shada = "'50,<20,s10,h" -- Trimmed ShaDa: faster startup

vim.o.showmode = false

vim.o.undofile = true

vim.o.inccommand = 'split'

vim.o.virtualedit = 'block'

vim.o.scrolloff = 10

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = 'yes'
vim.o.cursorline = true
vim.o.cursorlineopt = 'number'

vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = 'screen'

vim.o.laststatus = 3

vim.o.winborder = vim.g.border

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeoutlen = 400

vim.o.autoindent = true
vim.o.breakindent = true
vim.o.smarttab = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4

-- Keymaps ---------------------------------------------------------------------

vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<leader>q', function() vim.diagnostic.setloclist() end, { desc = 'Open diagnostic loclist' })

vim.keymap.set({ 'n', 'v' }, '<leader>fm', '<Cmd>Guard fmt<CR>', { desc = 'Format buffer' })
vim.keymap.set('n', '-', '<Cmd>Oil<CR>', { desc = 'Open parent directory' })

vim.keymap.set('n', '<leader>cc', function()
    require('colors').compile()
    vim.api.nvim_exec_autocmds('ColorScheme', {})
end, { desc = 'Recompile colorscheme' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>ff', '<Cmd>FzfLua files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fF', '<Cmd>FzfLua live_grep<CR>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fR', '<Cmd>FzfLua live_grep_resume<CR>', { desc = 'Resume live grep' })
vim.keymap.set('n', '<leader>/', '<Cmd>FzfLua blines<CR>', { desc = 'Search buffer lines' })
vim.keymap.set('n', '<leader>fb', '<Cmd>FzfLua buffers<CR>', { desc = 'Switch buffer' })
vim.keymap.set('n', '<leader>fM', '<Cmd>FzfLua marks<CR>', { desc = 'Marks' })
vim.keymap.set('n', '<leader>fh', '<Cmd>FzfLua help_tags<CR>', { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fk', '<Cmd>FzfLua keymaps<CR>', { desc = 'Keymaps' })
vim.keymap.set('n', '<leader>fc', '<Cmd>FzfLua commands<CR>', { desc = 'Commands' })
vim.keymap.set('n', '<leader>fg', '<Cmd>FzfLua git_status<CR>', { desc = 'Git status' })

vim.keymap.set('n', '<leader>m', '<Cmd>Mason<CR>', { desc = 'Open Mason' })

-- Commands --------------------------------------------------------------------

vim.api.nvim_create_autocmd('TextYankPost', {
    group = group,
    pattern = '*',
    desc = 'highlight selection on yank',
    callback = function() vim.hl.on_yank { timeout = 200, visual = true } end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    desc = 'restore cursor to file position in previous editing session',
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.api.nvim_win_set_cursor(0, mark)
            vim.schedule(function() vim.cmd 'normal! zz' end)
        end
    end,
})

vim.api.nvim_create_user_command(
    'MasonInstallAll',
    function()
        vim.cmd 'MasonInstall alejandra emmylua_ls goimports-reviser gopls nil oxfmt oxlint ruff stylua qmlls tailwindcss-language-server tsgo ty'
    end,
    {}
)

-- Bigfiles --------------------------------------------------------------------

do
    local BIGFILE = 1.5 * 1024 * 1024
    local LONGLINE = 1000 -- Catches minified bundles.

    local sizes = {} ---@type table<integer, integer>

    ---@param buf integer
    local function strip(buf)
        vim.b[buf].bigfile = true
        vim.bo[buf].swapfile = false
        vim.bo[buf].undofile = false
        vim.bo[buf].autocomplete = false

        vim.api.nvim_create_autocmd('BufWinEnter', {
            group = group,
            buffer = buf,
            once = true,
            callback = function()
                vim.bo[buf].syntax = ''
                vim.wo.foldmethod = 'manual'
                vim.wo.conceallevel = 0
            end,
        })
    end

    vim.api.nvim_create_autocmd('BufReadPre', {
        group = group,
        desc = 'bigfile: disable swap/undo before the read allocates for them',
        callback = function(ev)
            local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(ev.buf))
            if not stat or stat.type ~= 'file' then return end

            sizes[ev.buf] = stat.size
            if stat.size >= BIGFILE then strip(ev.buf) end
        end,
    })

    vim.api.nvim_create_autocmd('BufReadPost', {
        group = group,
        desc = 'bigfile: strip the expensive features off a file no one reads by eye',
        callback = function(ev)
            local size = sizes[ev.buf]
            sizes[ev.buf] = nil
            if not size or vim.b[ev.buf].bigfile then return end

            local lines = vim.api.nvim_buf_line_count(ev.buf)
            if lines > 0 and (size - lines) / lines >= LONGLINE then strip(ev.buf) end
        end,
    })
end

-- Dashboard -------------------------------------------------------------------

do
    local ns = vim.api.nvim_create_namespace 'dashboard'
    local config = vim.fs.joinpath(vim.fn.stdpath 'config', 'init.lua') ---@diagnostic disable-line

    ---@type [string, string, string][] key, label, command
    local items = {
        { 'f', 'find file', 'FzfLua files' },
        { 'r', 'recent', 'FzfLua oldfiles' },
        { 'g', 'grep', 'FzfLua live_grep' },
        { 'e', 'explorer', 'Oil' },
        { 'c', 'config', 'edit ' .. config },
        { 'q', 'quit', 'qall' },
    }

    local art = vim.split(
        [[
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣨⣽⣷⣾⣿⣿⣿⣿⣿⡿
⣿⣿⣿⣿⣿⠟⣿⣿⣿⣿⣿⣿⡿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣿⣿⣿⣿⣿⣧
⣿⣿⣿⣿⠏⠀⢹⣿⣿⡟⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣽
⣿⣿⣿⠏⠀⠀⠸⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣳⣿
⣿⣿⡟⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⢯⣿⣿
⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿
⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿
⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⡀⠀⡀⠄⠀⠀⠀⠀⣰⣿⢀⡇⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⣿⣿
⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣸⢃⠀⣴⠀⡴⣸⠁⠀⢠⠂⣰⣿⡇⣬⡅⢀⡀⢘⠀⠀⠀⠀⠀⠀⠀⣿⣿
⣿⣿⠀⠀⢸⡆⠀⠀⠀⠀⠀⠐⠉⠀⠀⠈⠉⠓⢿⠀⣰⠇⣴⣿⡿⣸⣿⠿⠼⠇⢿⠀⠀⠀⠀⠀⠀⠀⣿⣿
⣿⡏⡇⠀⠘⡇⠀⠀⠀⠀⠀⠀⠆⠀⠀⠀⠀⣷⣃⣼⣿⣾⣿⣿⣽⡏⠀⠀⠀⡀⣄⠀⠀⠀⠀⠀⠀⠀⣿⣿
⣿⣷⢻⡀⠀⠘⠀⠀⠀⠀⠀⠀⣾⢢⢽⣥⣾⣿⣿⣿⣿⣿⣿⣿⣿⣧⢤⡤⠀⣸⢏⡄⠀⠀⠀⠀⠀⠀⣿⣿
⣿⣿⣯⣇⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣤⣭⣽⣿⠃⠀⠀⠀⠀⠀⢀⣿⣿
⣿⣿⣿⣿⣿⣷⣠⠰⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿
⣿⣿⣿⣿⣿⣿⡿⢧⡧⠀⠂⠀⢠⠈⣟⢿⣿⣿⣿⣿⣿⣽⣿⣿⣿⣿⡿⢟⢡⢠⠇⠂⠀⠀⠀⠀⢀⣿⣿⣿
⣿⣿⠟⠀⠀⠀⠀⣾⣽⣦⠸⡄⠰⡄⠹⣿⣿⣟⡿⣿⣿⣿⣿⠛⣹⣷⣿⣿⣾⣼⡺⡆⠀⠀⠀⠾⣸⣿⣿⣿
⠟⠁⠀⠀⠀⠀⢠⣏⣿⣿⣧⣿⡀⣷⣄⠈⠛⠿⣿⣶⡶⠟⠃⢠⣿⣿⣿⣿⣿⣿⣇⡇⠀⠀⠀⠀⠀⠈⠛⢿
⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣷⣿⣿⣷⣄⡀⠀⠀⢀⣠⣴⣿⣿⣿⣿⣿⣿⣿⠻⠀⠀⠀⠀⠀⠀⠀⠀⠈
⠀⠀⠀⠀⠀⠀⢸⡟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        '\n',
        { trimempty = true }
    )

    local labels, label_width = {}, 0 ---@type string[], integer
    for i, item in ipairs(items) do
        labels[i] = ('%s  %s'):format(item[1], item[2])
        label_width = math.max(label_width, #labels[i])
    end
    local art_width = vim.api.nvim_strwidth(assert(art[1]))

    ---@param width integer
    ---@param block integer
    ---@return string
    local function pad(width, block) return (' '):rep(math.max(0, math.floor((width - block) / 2))) end

    ---@param buf integer
    ---@param win integer
    local function draw(buf, win)
        local width = vim.api.nvim_win_get_width(win)
        local art_pad, label_pad = pad(width, art_width), pad(width, label_width)
        local top = math.max(0, math.floor((vim.api.nvim_win_get_height(win) - #art - 1 - #labels) / 2))

        local lines = {} ---@type string[]
        for i = 1, top do
            lines[i] = ''
        end
        for _, text in ipairs(art) do
            lines[#lines + 1] = art_pad .. text
        end
        lines[#lines + 1] = ''
        for _, text in ipairs(labels) do
            lines[#lines + 1] = label_pad .. text
        end

        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

        for i in ipairs(art) do
            local line = top + i - 1 -- The `vim.hl.range` wrapper is way too slow per call + loads `vim.hl` at startup.
            vim.api.nvim_buf_set_extmark(buf, ns, line, #art_pad, { end_col = #lines[line + 1], hl_group = 'Title' })
        end
        for i in ipairs(labels) do
            local line = top + #art + i
            vim.api.nvim_buf_set_extmark(buf, ns, line, #label_pad, { end_col = #label_pad + 1, hl_group = 'Special' })
            vim.api.nvim_buf_set_extmark(
                buf,
                ns,
                line,
                #label_pad + 1,
                { end_col = #lines[line + 1], hl_group = 'Comment' }
            )
        end
    end

    vim.api.nvim_create_autocmd('VimEnter', {
        group = group,
        nested = true,
        desc = 'dashboard: a handful of keys on the otherwise empty start buffer',
        callback = function()
            if vim.fn.argc() > 0 or vim.bo.filetype ~= '' then return end
            if #vim.fn.getbufinfo { buflisted = 1 } > 1 then return end
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            if #lines > 1 or lines[1] ~= '' then return end

            local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
            vim.bo[buf].buftype = 'nofile'
            vim.bo[buf].bufhidden = 'wipe'
            vim.bo[buf].buflisted = false
            vim.bo[buf].filetype = 'dashboard'
            vim.wo[win][0].number = false
            vim.wo[win][0].relativenumber = false
            vim.wo[win][0].signcolumn = 'no'
            vim.wo[win][0].fillchars = 'eob: '

            draw(buf, win)

            for _, item in ipairs(items) do
                vim.keymap.set('n', item[1], '<Cmd>' .. item[3] .. '<CR>', { buffer = buf, nowait = true })
            end

            local guicursor = vim.o.guicursor
            vim.api.nvim_set_hl(0, 'DashboardCursor', { blend = 100, nocombine = true })
            vim.o.guicursor = 'a:DashboardCursor'

            local live = vim.api.nvim_create_augroup('dashboard.live', {})
            vim.api.nvim_create_autocmd('VimResized', {
                group = live,
                desc = 'dashboard: recenter on resize',
                callback = function() draw(buf, win) end,
            })

            vim.api.nvim_create_autocmd({ 'BufLeave', 'BufWipeout' }, {
                group = live,
                buffer = buf,
                once = true,
                desc = 'dashboard: restore the cursor and stop redrawing',
                callback = function()
                    vim.o.guicursor = guicursor
                    vim.api.nvim_clear_autocmds { group = live, event = 'VimResized' }
                end,
            })
        end,
    })
end

-- Plugins ---------------------------------------------------------------------

require('colors').setup()

local mason_path = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'bin') ---@diagnostic disable-line
if vim.uv.fs_stat(mason_path) then
    local delim = vim.fn.has 'win32' == 1 and ';' or ':'
    vim.env.PATH = mason_path .. delim .. vim.env.PATH
end

---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

vim.api.nvim_create_autocmd('PackChanged', {
    group = group,
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'nvim-treesitter' and kind == 'update' then
            if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
            vim.cmd 'TSUpdate'
        end
    end,
})

safe('later', function()
    vim.pack.add({
        gh 'nvim-mini/mini.icons', -- Icons
        gh 'nvim-mini/mini.snippets', -- Snippets
        gh 'nvimdev/guard.nvim', -- Formatter/Linter
        gh 'lukas-reineke/indent-blankline.nvim', -- Indentline
        gh 'windwp/nvim-autopairs', -- Autopairs
        gh 'stevearc/oil.nvim', -- Explorer
        gh 'nvim-treesitter/nvim-treesitter', -- Treesitter
        gh 'neovim/nvim-lspconfig', -- LSP
        gh 'lewis6991/gitsigns.nvim', -- Git
        gh 'rafamadriz/friendly-snippets', -- Snippet collection
        gh 'MeanderingProgrammer/render-markdown.nvim', -- Markdown
        gh 'ibhagwan/fzf-lua', -- Fuzzy
        gh 'mason-org/mason.nvim', -- Package manager
    }, { confirm = false, load = function() end })
end)

safe('event:InsertEnter', function()
    vim.cmd.packadd 'nvim-autopairs'
    require('nvim-autopairs').setup()
end)

safe('event:InsertEnter', function()
    vim.o.autocomplete = false
    vim.o.complete = 'o'
    vim.o.completeopt = 'fuzzy,nosort,menuone,noselect,popup'
    vim.o.autocompletedelay = 100
    vim.o.pumheight = 10
    vim.o.pumborder = vim.g.border -- `winborder` does not reach the popupmenu.

    vim.api.nvim_create_autocmd({ 'InsertEnter', 'InsertLeave' }, {
        group = group,
        callback = function() vim.bo.autocomplete = false end,
    })

    vim.api.nvim_create_autocmd('InsertCharPre', {
        group = group,
        callback = function()
            if not vim.bo.autocomplete then vim.bo.autocomplete = true end
        end,
    })

    vim.keymap.set('i', '<Tab>', function()
        if vim.fn.pumvisible() == 0 then return '<Tab>' end
        if vim.fn.complete_info({ 'selected' }).selected == -1 then return '<C-n><C-y>' end
        return '<C-y>'
    end, { expr = true, desc = 'Accept completion' })

    vim.cmd.packadd 'friendly-snippets'
    vim.cmd.packadd 'mini.snippets'
    local snippets = require 'mini.snippets'
    snippets.setup { snippets = { snippets.gen_loader.from_lang() } }
    snippets.start_lsp_server()
end)

safe('cmd:Guard', function()
    vim.g.guard_config = { fmt_on_save = false, save_on_fmt = true }

    vim.cmd.packadd 'guard.nvim'
    local ft = require 'guard.filetype'

    ---@param filetypes string
    ---@param configs (table|string)[] The first entry becomes `:fmt`, the rest `:append`.
    local function fmt(filetypes, configs)
        for _, config in ipairs(configs) do
            if type(config) == 'table' and config.cmd and vim.fn.executable(config.cmd) ~= 1 then return end
        end

        ---@diagnostic disable-next-line
        local handler = ft(filetypes):fmt(configs[1])
        for i = 2, #configs do
            handler = handler:append(configs[i])
        end
    end

    fmt('qml', { 'lsp' })
    fmt('go', { { cmd = 'goimports', args = { '-format', '-output', 'stdout', '-file-path' }, fname = true } })
    fmt('javascript,javascriptreact,typescript,typescriptreact,css,scss,less', {
        {
            cmd = 'oxfmt',
            args = { '--stdin-filepath' },
            fname = true,
            stdin = true,
        },
    })
    fmt('lua', { { cmd = 'stylua', args = { '-' }, stdin = true } })
    fmt('nix', { { cmd = 'alejandra', args = { '--quiet', '-' }, stdin = true } })
    fmt('python', {
        { cmd = 'ruff', args = { 'check', '--fix', '--quiet', '-', '--stdin-filename' }, fname = true, stdin = true },
        { cmd = 'ruff', args = { 'format', '--quiet', '-', '--stdin-filename' }, fname = true, stdin = true },
    })
end)

safe('cmd:TSInstall,TSInstallFromGrammar,TSUpdate,TSUninstall,TSLog', function() vim.cmd.packadd 'nvim-treesitter' end)

safe('cmd:Oil', function()
    vim.cmd.packadd 'oil.nvim'
    require('oil').setup {
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        view_options = {
            show_hidden = true,
            natural_order = true,
            is_always_hidden = function(name) return name == '..' or name == '.git' end,
        },
        win_options = { wrap = true },
    }
end)

safe('cmd:Mason,MasonInstall,MasonInstallAll,MasonUninstall,MasonUninstallAll,MasonUpdate', function()
    vim.cmd.packadd 'mason.nvim'
    ---@diagnostic disable-next-line
    require('mason').setup {
        PATH = 'skip',
        ui = {
            icons = {
                package_pending = ' ',
                package_installed = ' ',
                package_uninstalled = ' ',
            },
        },
        max_concurrent_installers = 10,
    }
end)

local eventignore = vim.o.eventignore
vim.o.eventignore = 'FileType'

-- Queue drains top to bottom.

safe('later', function()
    vim.cmd.packadd 'mini.icons'
    local icons = require 'mini.icons'
    icons.setup()
    icons.mock_nvim_web_devicons()
end)

safe('later', function()
    vim.cmd.packadd 'nvim-treesitter'
    vim.treesitter.language.register('bash', 'sh')
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        desc = 'treesitter: start highlighting and indenting',
        callback = function(ev)
            if vim.b[ev.buf].bigfile then return end
            if not vim.treesitter.highlighter.active[ev.buf] and not pcall(vim.treesitter.start, ev.buf) then return end
            local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
            if lang and vim.treesitter.query.get(lang, 'indents') then
                vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end,
    })

    local parsers = {
        'bash',
        'c',
        'css',
        'diff',
        'git_config',
        'git_rebase',
        'gitcommit',
        'gitignore',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'html',
        'javascript',
        'jsdoc',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'nix',
        'python',
        'query',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
    }

    local installed = {} ---@type table<string, true> One glob over the runtime path instead of one per language.
    for _, path in ipairs(vim.api.nvim_get_runtime_file('parser/*', true)) do
        installed[vim.fn.fnamemodify(path, ':t:r')] = true
    end

    local missing = {}
    for _, lang in ipairs(parsers) do
        if not installed[lang] then missing[#missing + 1] = lang end
    end
    if #missing == 0 then return end

    local install = require('nvim-treesitter').install(missing)

    async(function()
        local err = await(2, install.await, install)
        if err then error(err) end

        if vim.v.exiting == vim.NIL then vim.api.nvim_exec_autocmds('FileType', { buffer = 0 }) end
    end)
end)

safe('later', function()
    vim.cmd.packadd 'nvim-lspconfig'
    vim.lsp.config('*', {
        on_init = function(client)
            client.server_capabilities.semanticTokensProvider = nil
            if client.name ~= 'tailwindcss' then client.server_capabilities.colorProvider = nil end
        end,
    })

    vim.lsp.document_color.enable(true, nil, { style = vim.g.swatch })
    vim.lsp.enable(vim.tbl_filter(function(name)
        local cmd = vim.lsp.config[name].cmd ---@diagnostic disable-line
        return type(cmd) ~= 'table' or vim.fn.executable(cmd[1]) == 1
    end, {
        'emmylua_ls',
        'gopls',
        'nil_ls',
        'oxlint',
        'ruff',
        'tailwindcss',
        'tsc',
        'ty',
        'qmlls',
    }))
end)

safe('later', function()
    vim.cmd.packadd 'indent-blankline.nvim'
    require('ibl').setup {
        indent = { char = '│', highlight = 'IblChar' },
        scope = { enabled = false },
    }

    local hooks = require 'ibl.hooks'
    hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
end)

safe('later', function()
    vim.o.eventignore = eventignore

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= '' then
            vim.api.nvim_buf_call(
                buf,
                function() vim.api.nvim_exec_autocmds('FileType', { buffer = buf, modeline = false }) end
            )
        end
    end
end)

safe('event:FileType~markdown,markdown_inline,rmd,quarto', function()
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd.packadd 'render-markdown.nvim'
    vim.api.nvim_exec_autocmds('FileType', { buffer = buf, modeline = false })
end)

safe('later', function()
    vim.cmd.packadd 'gitsigns.nvim'
    require('gitsigns').setup {}
end)

local fzf = safe('once', function()
    vim.cmd.packadd 'fzf-lua'
    require('fzf-lua').setup {
        file_icon_padding = ' ',
        fzf_opts = { ['--no-scrollbar'] = true },
        fzf_colors = true,
        winopts = { border = vim.g.border, preview = { border = vim.g.border } },
    }

    require('fzf-lua').register_ui_select()
end)

safe('cmd:FzfLua', fzf)

safe('later', function()
    local builtin = vim.ui.select
    local pending ---@type fun(items: any[], opts: table, on_choice: function)

    pending = function(...)
        fzf()
        -- fzf-lua `register_ui_select` replaced the stub;
        if vim.ui.select == pending then vim.ui.select = builtin end ---@diagnostic disable-line
        return vim.ui.select(...)
    end

    vim.ui.select = pending
end)

safe('later', function()
    vim.cmd.runtime 'plugin/osc52.lua' -- `loadplugins = false` skipped it.
    vim.o.clipboard = 'unnamedplus'
end)

-- LSP -------------------------------------------------------------------------

do
    local MAXWIDTH, MAXHEIGHT = 40, 10

    local signature = debounce(50, function()
        if vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' then
            vim.lsp.buf.signature_help {
                silent = true,
                focus = false,
                max_height = MAXHEIGHT,
                close_events = { 'InsertLeave', 'BufLeave' },
                anchor_bias = 'above',
            }
        end
    end)

    ---@param word string
    ---@param buf integer Buffer the symbol lives in.
    local function prompt(word, buf)
        local float = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(float, 0, -1, false, { word })
        local above = vim.fn.winline() + 3 > vim.api.nvim_win_get_height(0)
        local win = vim.api.nvim_open_win(float, true, {
            relative = 'cursor',
            anchor = above and 'SW' or 'NW',
            row = above and 0 or 1,
            col = 0,
            width = math.max(#word + 8, 24),
            height = 1,
            style = 'minimal',
            title = { { ' 󰑕 rename ', 'FloatTitle' } },
            title_pos = 'center',
        })
        vim.wo[win].scrolloff = 0

        local done = false

        ---@param confirm boolean
        local function finish(confirm)
            if done then return end
            done = true

            local text = confirm and vim.trim(assert(vim.api.nvim_buf_get_lines(float, 0, 1, false)[1]))
            vim.lsp.util.buf_clear_references(buf)
            vim.api.nvim_buf_delete(float, { force = true })
            vim.cmd 'stopinsert'

            if text and text ~= '' and text ~= word then vim.lsp.buf.rename(text) end
        end

        vim.keymap.set({ 'i', 'n' }, '<CR>', function() finish(true) end, { buffer = float })
        vim.keymap.set({ 'i', 'n' }, '<Esc>', function() finish(false) end, { buffer = float })
        vim.api.nvim_create_autocmd('WinLeave', {
            buffer = float,
            once = true,
            desc = 'rename: never leave the prompt orphaned behind another window',
            callback = function()
                vim.schedule(function() finish(false) end)
            end,
        })

        vim.cmd 'startinsert!'
    end

    local function rename()
        local word = vim.fn.expand '<cword>'
        if word == '' then return end
        ---@cast word string

        local buf = vim.api.nvim_get_current_buf()
        vim.lsp.buf.document_highlight()

        local client = vim.lsp.get_clients({ bufnr = buf, method = 'textDocument/prepareRename' })[1]
        if not client then return prompt(word, buf) end

        local enc = client.offset_encoding
        client:request('textDocument/prepareRename', vim.lsp.util.make_position_params(0, enc), function(err, res)
            local range = not err and res and (res.range or res.start and res) or nil
            if res and res.placeholder then
                word = res.placeholder
            elseif range then
                local line = vim.api.nvim_buf_get_lines(buf, range.start.line, range.start.line + 1, false)[1] or ''
                local from = vim.str_byteindex(line, enc, range.start.character, false)
                word = line:sub(from + 1, vim.str_byteindex(line, enc, range['end'].character, false))
            end

            prompt(word, buf)
        end, buf)
    end

    safe('later', function()
        vim.diagnostic.config {
            update_in_insert = true,
            severity_sort = true,
            underline = { severity = { min = vim.diagnostic.severity.WARN, max = vim.diagnostic.severity.ERROR } },
            virtual_text = { prefix = '' },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '󰅙',
                    [vim.diagnostic.severity.WARN] = '',
                    [vim.diagnostic.severity.INFO] = '󰋼',
                    [vim.diagnostic.severity.HINT] = '󰌵',
                },
            },
            float = { source = 'if_many' },
            jump = {
                on_jump = function(_, bufnr)
                    vim.diagnostic.open_float {
                        bufnr = bufnr,
                        scope = 'cursor',
                        focus = false,
                    }
                end,
            },
        }
    end)

    vim.api.nvim_create_autocmd('LspAttach', {
        group = group,
        desc = 'lsp: enable per-buffer features',
        callback = function(ev)
            local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
            if not vim.api.nvim_buf_is_valid(ev.buf) then return end

            vim.keymap.set('n', 'gd', '<Cmd>FzfLua lsp_definitions<CR>', { buffer = ev.buf })
            vim.keymap.set('n', 'gD', '<Cmd>FzfLua lsp_declarations<CR>', { buffer = ev.buf })
            vim.keymap.set('n', 'gr', '<Cmd>FzfLua lsp_references<CR>', { buffer = ev.buf })
            vim.keymap.set('n', 'gi', '<Cmd>FzfLua lsp_implementations<CR>', { buffer = ev.buf })
            vim.keymap.set('n', 'gt', '<Cmd>FzfLua lsp_typedefs<CR>', { buffer = ev.buf })
            vim.keymap.set('n', 'gs', '<Cmd>FzfLua lsp_document_symbols<CR>', { buffer = ev.buf })
            vim.keymap.set('n', 'gS', '<Cmd>FzfLua lsp_workspace_symbols<CR>', { buffer = ev.buf })
            vim.keymap.set('n', 'gO', '<Cmd>FzfLua lsp_outgoing_calls<CR>', { buffer = ev.buf })
            vim.keymap.set('n', 'gI', '<Cmd>FzfLua lsp_incoming_calls<CR>', { buffer = ev.buf })
            vim.keymap.set('n', 'gq', '<Cmd>FzfLua lsp_document_diagnostics<CR>', { buffer = ev.buf })
            vim.keymap.set({ 'n', 'x' }, 'ga', '<Cmd>FzfLua lsp_code_actions<CR>', { buffer = ev.buf })

            if client:supports_method('textDocument/hover', ev.buf) then
                vim.keymap.set('n', 'K', function()
                    local names = vim
                        .iter(vim.lsp.get_clients { bufnr = 0, method = 'textDocument/hover' }) ---@diagnostic disable-line
                        :map(function(c) return c.name end)
                        :join ', '
                    vim.lsp.buf.hover { title = (' %s '):format(names) }
                end, { buffer = ev.buf, desc = 'Hover' })
            end

            if client:supports_method('textDocument/rename', ev.buf) then
                vim.keymap.set('n', 'grn', rename, { buffer = ev.buf, desc = 'Rename symbol' })
            end

            if client:supports_method('textDocument/documentHighlight', ev.buf) then
                vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                    buffer = ev.buf,
                    group = group,
                    callback = vim.lsp.buf.document_highlight,
                })

                vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                    buffer = ev.buf,
                    group = group,
                    callback = vim.lsp.buf.clear_references,
                })

                vim.api.nvim_create_autocmd('LspDetach', {
                    group = group,
                    buffer = ev.buf,
                    callback = function(ev2)
                        vim.lsp.util.buf_clear_references(ev2.buf)
                        vim.api.nvim_clear_autocmds {
                            group = group,
                            buffer = ev2.buf,
                            event = {
                                'CursorHold',
                                'CursorHoldI',
                                'CursorMoved',
                                'CursorMovedI',
                                'TextChangedI',
                                'BufWritePre',
                                'LspDetach',
                            },
                        }
                    end,
                })
            end

            if client:supports_method 'textDocument/completion' then
                vim.lsp.completion.enable(true, client.id, ev.buf, {
                    autotrigger = false,
                    convert = function(item)
                        local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or 'Text'
                        local label = vim.trim(item.label)
                        local detail = vim.tbl_get(item, 'labelDetails', 'detail')
                        if detail then label = label .. vim.trim(detail) end

                        if vim.fn.strdisplaywidth(label) > MAXWIDTH then
                            label = vim.fn.strcharpart(label, 0, MAXWIDTH - 1) .. '…'
                        end

                        local icon, hl = _G.MiniIcons.get('lsp', kind)
                        return {
                            abbr = label,
                            kind = icon .. ' ',
                            kind_hlgroup = kind ~= 'Color' and hl or nil,
                            menu = kind,
                        }
                    end,
                })
            end

            local provider = client:supports_method 'textDocument/signatureHelp'
                and assert(client.server_capabilities).signatureHelpProvider
            if type(provider) == 'table' then
                local triggers = {} ---@type table<string, true>
                for _, chars in ipairs { provider.triggerCharacters or {}, provider.retriggerCharacters or {} } do
                    for _, char in ipairs(chars) do
                        triggers[char] = true
                    end
                end

                ---@return boolean?
                local function at_trigger()
                    local col = vim.api.nvim_win_get_cursor(0)[2]
                    local line = vim.api.nvim_get_current_line()
                    local before = line:sub(1, col):gsub('%s+$', '')
                    return triggers[before:sub(-1)] or triggers[line:sub(col + 1, col + 1)]
                end

                vim.api.nvim_create_autocmd('TextChangedI', {
                    group = group,
                    buffer = ev.buf,
                    desc = 'lsp: signature help around a trigger character',
                    callback = function()
                        if at_trigger() then return signature() end

                        local win = vim.b.lsp_floating_preview
                        if win and vim.api.nvim_win_is_valid(win) and vim.w[win]['textDocument/signatureHelp'] then
                            vim.api.nvim_win_close(win, true)
                        end
                    end,
                })
            end

            if client:supports_method('textDocument/inlayHint', ev.buf) then
                vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
                vim.keymap.set('n', '<leader>th', function()
                    local buf = vim.api.nvim_get_current_buf()
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf }, { bufnr = buf })
                end, { buffer = ev.buf, desc = 'Toggle inlay hints' })
            end
        end,
    })
end

-- Statusline ------------------------------------------------------------------

do
    local memo = {} ---@type table<integer, table<string, string>>

    ---@param slot table<string, string>
    ---@param buf integer
    ---@param name string
    ---@param build fun(buf: integer): string
    ---@return string
    local function segment(slot, buf, name, build)
        local hit = slot[name]
        if hit then return hit end ---@diagnostic disable-line

        hit = build(buf)
        slot[name] = hit
        return hit
    end

    local modes = {
    -- stylua: ignore start
        ['n']     = { name = 'NORMAL',          hl = 'StatusLineModeNormal' },
        ['no']    = { name = 'NORMAL·PENDING',  hl = 'StatusLineModeNormal' },
        ['nov']   = { name = 'NORMAL·PENDING',  hl = 'StatusLineModeNormal' },
        ['noV']   = { name = 'NORMAL·PENDING',  hl = 'StatusLineModeNormal' },
        ['no\22'] = { name = 'NORMAL·PENDING',  hl = 'StatusLineModeNormal' },
        ['niI']   = { name = 'NORMAL·INSERT',   hl = 'StatusLineModeNormal' },
        ['niR']   = { name = 'NORMAL·REPLACE',  hl = 'StatusLineModeNormal' },
        ['niV']   = { name = 'NORMAL·VISUAL',   hl = 'StatusLineModeNormal' },
        ['nt']    = { name = 'NORMAL·TERMINAL', hl = 'StatusLineModeNormal' },
        ['ntT']   = { name = 'NORMAL·TERMINAL', hl = 'StatusLineModeNormal' },

        ['v']    = { name = 'VISUAL',       hl = 'StatusLineModeVisual' },
        ['vs']   = { name = 'VISUAL',       hl = 'StatusLineModeVisual' },
        ['V']    = { name = 'VISUAL·LINE',  hl = 'StatusLineModeVisual' },
        ['Vs']   = { name = 'VISUAL·LINE',  hl = 'StatusLineModeVisual' },
        ['\22']  = { name = 'VISUAL·BLOCK', hl = 'StatusLineModeVisual' },
        ['\22s'] = { name = 'VISUAL·BLOCK', hl = 'StatusLineModeVisual' },

        ['s']   = { name = 'SELECT',       hl = 'StatusLineModeVisual' },
        ['S']   = { name = 'SELECT·LINE',  hl = 'StatusLineModeVisual' },
        ['\19'] = { name = 'SELECT·BLOCK', hl = 'StatusLineModeVisual' },

        ['i']  = { name = 'INSERT', hl = 'StatusLineModeInsert' },
        ['ic'] = { name = 'INSERT', hl = 'StatusLineModeInsert' },
        ['ix'] = { name = 'INSERT', hl = 'StatusLineModeInsert' },

        ['R']   = { name = 'REPLACE',            hl = 'StatusLineModeReplace' },
        ['Rc']  = { name = 'REPLACE·COMPLETION', hl = 'StatusLineModeReplace' },
        ['Rx']  = { name = 'REPLACE·COMPLETION', hl = 'StatusLineModeReplace' },
        ['Rv']  = { name = 'VIRTUAL·REPLACE',    hl = 'StatusLineModeReplace' },
        ['Rvc'] = { name = 'VIRTUAL·REPLACE',    hl = 'StatusLineModeReplace' },
        ['Rvx'] = { name = 'VIRTUAL·REPLACE',    hl = 'StatusLineModeReplace' },

        ['c']  = { name = 'COMMAND', hl = 'StatusLineModeCommand' },
        ['cv'] = { name = 'EX',      hl = 'StatusLineModeCommand' },
        ['r']  = { name = 'PROMPT',  hl = 'StatusLineModeCommand' },
        ['rm'] = { name = 'MORE',    hl = 'StatusLineModeCommand' },
        ['r?'] = { name = 'CONFIRM', hl = 'StatusLineModeCommand' },
        ['!']  = { name = 'SHELL',   hl = 'StatusLineModeCommand' },

        ['t'] = { name = 'TERMINAL', hl = 'StatusLineModeTerminal' },
        -- stylua: ignore end
    }

    local fileicons = {} ---@type table<string, string>
    local names = {} ---@type table<integer, string>

    ---@param buf integer
    ---@return string
    local function file(buf)
        local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })

        local icon = fileicons[ft]
        if icon == nil then
            if _G.MiniIcons then
                local glyph, hl = _G.MiniIcons.get('filetype', ft) -- `get` lowercases and caches
                if not glyph or glyph == '' then glyph = '󰈚' end
                icon = hl and string.format(' %%#%s#%s%%* ', hl, glyph) or ' ' .. glyph .. ' '
                fileicons[ft] = icon
            else
                icon = ' 󰈚 '
            end
        end

        local name = names[buf]
        if not name then
            local path = vim.api.nvim_buf_get_name(buf)
            name = path:match '([^/\\]+)[/\\]*$' or '[No Name]'
            names[buf] = name
        end
        if vim.api.nvim_get_option_value('modified', { buf = buf }) then name = name .. ' ' end
        if vim.api.nvim_get_option_value('readonly', { buf = buf }) then name = name .. ' ' end

        return icon .. name .. ' '
    end

    local severities ---@type [vim.diagnostic.Severity, string][]?
    local unknown = { name = '?', hl = 'StatusLineModeNormal' }
    local rendered = {} ---@type table<string, string>

    ---@return string
    local function mode()
        local m = vim.api.nvim_get_mode().mode
        local hit = rendered[m]
        if hit then return hit end ---@diagnostic disable-line

        local info = modes[m] or unknown
        hit = '%#' .. info.hl .. '# ' .. info.name .. ' %* '
        rendered[m] = hit
        return hit
    end

    ---@param buf integer
    ---@return string
    local function diagnostics(buf)
        if not package.loaded['vim.diagnostic'] then return '' end

        if not severities then
            severities = {
                { vim.diagnostic.severity.ERROR, 'StatusLineDiagnosticError' },
                { vim.diagnostic.severity.WARN, 'StatusLineDiagnosticWarn' },
                { vim.diagnostic.severity.INFO, 'StatusLineDiagnosticInfo' },
                { vim.diagnostic.severity.HINT, 'StatusLineDiagnosticHint' },
            }
        end

        local icons = vim.tbl_get(vim.diagnostic.config() or {}, 'signs', 'text') or {}
        local parts = {}

        local counts = vim.diagnostic.count(buf)
        for _, severity in ipairs(severities) do
            local n = counts[severity[1]]
            if n and n > 0 then
                parts[#parts + 1] = '%#' .. severity[2] .. '#' .. (icons[severity[1]] or '') .. ' ' .. n .. ' %*'
            end
        end

        return #parts == 0 and '' or ' ' .. table.concat(parts) .. ' '
    end

    local gitparts = {
        { 'added', 'StatusLineGitAdd', '+' },
        { 'changed', 'StatusLineGitChange', '~' },
        { 'removed', 'StatusLineGitDelete', '-' },
    }

    ---@param buf integer
    ---@return string
    local function git(buf)
        local ok, status = pcall(vim.api.nvim_buf_get_var, buf, 'gitsigns_status_dict')
        if not ok or not status.head or status.head == '' then return '' end

        local branch = ' ' .. status.head .. ' '
        local out = ' ' .. branch
        for _, part in ipairs(gitparts) do
            local n = status[part[1]]
            if n and n ~= 0 then out = out .. '%#' .. part[2] .. '#' .. part[3] .. n .. ' %*' end
        end

        return out .. ' '
    end

    local sbar = { '▁▁', '▂▂', '▃▃', '▄▄', '▅▅', '▆▆', '▇▇', '██' }
    local totals = {} ---@type table<integer, integer>

    ---@return string
    local function position()
        local win = vim.g.statusline_winid or 0
        local cursor = vim.api.nvim_win_get_cursor(win)
        local row = cursor[1]

        local buf = vim.api.nvim_win_get_buf(win)
        local total = totals[buf]
        if not total then
            total = math.max(vim.api.nvim_buf_line_count(buf), 1)
            totals[buf] = total
        end

        local i = math.min(math.max(math.floor((row - 1) * #sbar / total) + 1, 1), #sbar)

        return string.format(
            '%d:%d %d%%  %%#StatusLineMap#%s%%*',
            row,
            cursor[2] + 1,
            math.floor(row * 100 / total),
            sbar[i]
        )
    end

    local refresh = debounce(100, function() vim.cmd.redrawstatus { mods = { emsg_silent = true } } end)

    vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'GitSignsUpdate',
        desc = 'statusline: refresh git counts',
        callback = function(ev)
            local slot = memo[ev.data and ev.data.buffer or ev.buf]
            if slot then slot.git = nil end ---@diagnostic disable-line
            refresh()
        end,
    })

    vim.api.nvim_create_autocmd('DiagnosticChanged', {
        group = group,
        desc = 'statusline: refresh diagnostic counts',
        callback = function(ev)
            local slot = memo[ev.buf]
            if slot then slot.diagnostics = nil end ---@diagnostic disable-line
            refresh()
        end,
    })

    vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufDelete' }, {
        group = group,
        desc = 'statusline: drop the memo of a gone buffer',
        callback = function(ev)
            memo[ev.buf] = nil
            names[ev.buf] = nil
            totals[ev.buf] = nil
        end,
    })

    vim.api.nvim_create_autocmd({ 'BufFilePre', 'BufFilePost' }, {
        group = group,
        desc = 'statusline: drop the cached name of a renamed buffer',
        callback = function(ev) names[ev.buf] = nil end,
    })

    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
        group = group,
        desc = 'statusline: drop the cached line count',
        callback = function(ev) totals[ev.buf] = nil end,
    })

    ---@return string
    function _G.statusline()
        local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
        local slot = memo[buf]
        if not slot then
            slot = {}
            memo[buf] = slot
        end

        -- `%<` before the left group: a narrow split eats filename/branch, never the cursor position on the right.
        return mode()
            .. '%<'
            .. file(buf)
            .. segment(slot, buf, 'git', git)
            .. '%='
            .. segment(slot, buf, 'diagnostics', diagnostics)
            .. position()
    end

    vim.o.statusline = '%{%v:lua.statusline()%}'
end

-- Highlight -------------------------------------------------------------------

do
    local ns = vim.api.nvim_create_namespace 'patterns'

    local keywords = {
        TODO = vim.api.nvim_get_hl_id_by_name 'PatternTodo',
        FIXME = vim.api.nvim_get_hl_id_by_name 'PatternFixme',
        HACK = vim.api.nvim_get_hl_id_by_name 'PatternHack',
        NOTE = vim.api.nvim_get_hl_id_by_name 'PatternNote',
        WARN = vim.api.nvim_get_hl_id_by_name 'PatternWarn',
        PERF = vim.api.nvim_get_hl_id_by_name 'PatternPerf',
        TEST = vim.api.nvim_get_hl_id_by_name 'PatternTest',
    }

    local MAX_LINE = 400 -- Skip minified lines: no eye reads them anyway.
    local PRIORITY = 200 -- Above treesitter and diagnostics.
    local MAX_SWATCHES = 10000 -- Highlight groups are never reclaimed; cap the leak.
    local SWATCH = vim.g.swatch

    local swatches, states = {}, {} ---@type table<string, integer>, table<integer, { tick: integer, rows: table<integer, true> }>
    local nswatches = 0

    ---@param buf integer
    ---@param row integer
    ---@param col integer
    ---@param hex string
    local function dot(buf, row, col, hex)
        local id = swatches[hex]
        if not id then
            if nswatches >= MAX_SWATCHES then return end

            local name = 'Pattern' .. hex:sub(2)
            id = vim.api.nvim_get_hl_id_by_name(name)
            swatches[hex] = id
            nswatches = nswatches + 1
            vim.schedule(function() vim.api.nvim_set_hl(0, name, { fg = hex }) end)
        end

        vim.api.nvim_buf_set_extmark(buf, ns, row, col - 1, {
            virt_text = { { SWATCH, id } },
            virt_text_pos = 'inline',
            priority = PRIORITY,
        })
    end

    ---@param buf integer
    ---@param row integer
    ---@param line string
    local function scan(buf, row, line)
        for col, word, stop in line:gmatch '()%f[%w](%u%u%u%u+)%f[%W]():' do
            local id = keywords[word]
            if id then ---@diagnostic disable-line
                vim.api.nvim_buf_set_extmark(
                    buf,
                    ns,
                    row,
                    assert(tonumber(col)) - 1,
                    { end_col = assert(tonumber(stop)) - 1, hl_group = id, priority = PRIORITY }
                )
            end
        end

        for col, hex in line:gmatch '()#(%x+)%f[%W]' do
            local num, size = assert(tonumber(col)), #hex
            if size == 3 or size == 4 then
                dot(buf, row, num, '#' .. (hex:gsub('%x', '%0%0')):sub(1, 6))
            elseif size == 6 or size == 8 then
                dot(buf, row, num, '#' .. hex:sub(1, 6))
            end
        end
    end

    vim.api.nvim_set_decoration_provider(ns, {
        on_win = function(_, _, buf, top, bot)
            if vim.b[buf].bigfile then return false end
            if vim.api.nvim_get_option_value('buftype', { buf = buf }) ~= '' then return false end

            local tick = vim.api.nvim_buf_get_changedtick(buf)
            local state = states[buf]
            if not state or state.tick ~= tick then
                state = { tick = tick, rows = {} }
                states[buf] = state
            end

            local rows = state.rows
            local first, last
            for row = top, bot do
                if not rows[row] then
                    first, last = first or row, row
                end
            end
            if not first then return false end
            ---@cast last integer

            local lines = vim.api.nvim_buf_get_lines(buf, first, last + 1, false)
            vim.api.nvim_buf_clear_namespace(buf, ns, first, last + 1) -- The whole range is rewritten below.
            for i = 1, #lines do
                local row, line = first + i - 1, lines[i]
                rows[row] = true
                if #line <= MAX_LINE then scan(buf, row, line) end
            end

            return false
        end,
    })

    vim.keymap.set('n', '<leader>ft', function()
        fzf()
        require('fzf-lua').grep {
            search = ([[\b(%s):]]):format(table.concat(vim.tbl_keys(keywords), '|')),
            no_esc = true,
            prompt = '> ',
            headers = false,
        }
    end, { desc = 'Find keyword comments' })

    vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufDelete' }, {
        group = group,
        desc = 'patterns: drop the scan state of a gone buffer',
        callback = function(ev) states[ev.buf] = nil end,
    })

    vim.api.nvim_create_autocmd('ColorScheme', {
        group = group,
        desc = 'patterns: repaint the swatch groups that `hi clear` wiped',
        callback = function()
            for hex in pairs(swatches) do
                vim.api.nvim_set_hl(0, 'Pattern' .. hex:sub(2), { fg = hex })
            end
        end,
    })
end
