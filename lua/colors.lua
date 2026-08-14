-- Palette: https://github.com/vague-theme/vague.nvim
local o0 = '#141415' -- Background
local o1 = '#1c1c24' -- Lighter background (floats, cursorline)
local o2 = '#252530' -- Selection background
local o3 = '#606079' -- Comments, line numbers, invisibles
local o4 = '#878787' -- Dim foreground
local o5 = '#cdcdcd' -- Default foreground
local o7 = '#f3be7c' -- Bright foreground (accents)
local o8 = '#d8647e' -- Red
local o9 = '#e0a363' -- Orange
local oa = '#f3be7c' -- Yellow
local ob = '#7fa563' -- Green
local oc = '#b4d4cf' -- Cyan
local od = '#6e94b2' -- Blue
local oe = '#c48282' -- Magenta
local of = '#9bb4bc' -- Brown/punctuation

local hl = {
    -- Syntax
    Boolean = { fg = o9 },
    Character = { fg = o8 },
    Conditional = { fg = oe },
    Constant = { fg = o9 },
    Define = { fg = oe },
    Delimiter = { fg = of },
    Float = { fg = o9 },
    Function = { fg = od },
    Identifier = { fg = o8 },
    Include = { fg = od },
    Keyword = { fg = oe },
    Label = { fg = oa },
    Number = { fg = o9 },
    Operator = { fg = o5 },
    PreProc = { fg = oa },
    Repeat = { fg = oa },
    Special = { fg = oc },
    SpecialChar = { fg = of },
    Statement = { fg = o8 },
    StorageClass = { fg = oa },
    String = { fg = ob },
    Structure = { fg = oe },
    Tag = { fg = oa },
    Todo = { fg = oa, bg = o1 },
    Type = { fg = oa },
    Typedef = { fg = oa },
    Variable = { fg = o5 },

    PreCondit = { fg = oa },
    SpecialComment = { fg = o4 },
    Underlined = { underline = true },
    Ignore = { fg = o3 },

    Comment = { fg = o4 },
    Debug = { fg = o8 },
    Error = { fg = o0, bg = o8 },
    Exception = { fg = o8 },
    Macro = { fg = o8 },
    TooLong = { fg = o8 },

    Normal = { fg = o5, bg = o0 },
    NormalFloat = { fg = o5, bg = o1 },
    FloatBorder = { fg = o1, bg = o1 },
    FloatTitle = { fg = o0, bg = od, bold = true },
    WinSeparator = { fg = o2 },
    WinBar = { fg = o5 },
    WinBarNC = { fg = o3 },

    Cursor = { fg = o0, bg = o5 },
    CursorLine = { bg = o1 },
    CursorColumn = { bg = o1 },
    CursorLineNr = { fg = o5 },
    ColorColumn = { bg = o1 },
    LineNr = { fg = o3 },
    SignColumn = { fg = o3 },
    FoldColumn = { fg = of },
    Folded = { fg = o4, bg = o1 },
    NonText = { fg = o3 },
    Whitespace = { fg = o2 },
    SpecialKey = { fg = o3 },
    Conceal = { bg = 'NONE' },
    Directory = { fg = od },
    Title = { fg = od },
    QuickFixLine = { bg = o1 },
    healthSuccess = { fg = o0, bg = ob },

    Visual = { bg = o2 },
    VisualNOS = { fg = o8 },
    Search = { fg = o0, bg = oa },
    IncSearch = { fg = o0, bg = o9 },
    CurSearch = { link = 'IncSearch' },
    Substitute = { fg = o0, bg = oa },
    MatchWord = { fg = o5, bg = o3 },
    MatchParen = { link = 'MatchWord' },

    ModeMsg = { fg = ob },
    MoreMsg = { fg = ob },
    Question = { fg = od },
    ErrorMsg = { fg = o8, bg = o0 },
    WarningMsg = { fg = o8 },
    NvimInternalError = { fg = o8 },

    -- Statusline
    StatusLine = { fg = o3, bg = o1 },
    StatusLineNC = { fg = o3, bg = o1 },
    StatusLineModeNormal = { fg = o0, bg = od, bold = true },
    StatusLineModeVisual = { fg = o0, bg = oc, bold = true },
    StatusLineModeInsert = { fg = o0, bg = oe, bold = true },
    StatusLineModeReplace = { fg = o0, bg = o9, bold = true },
    StatusLineModeCommand = { fg = o0, bg = ob, bold = true },
    StatusLineModeTerminal = { fg = o0, bg = ob, bold = true },
    StatusLineGitAdd = { fg = ob, bg = o1 },
    StatusLineGitChange = { fg = oa, bg = o1 },
    StatusLineGitDelete = { fg = o8, bg = o1 },
    StatusLineMap = { fg = of, bg = o1 },
    StatusLineDiagnosticError = { fg = o8, bg = o1 },
    StatusLineDiagnosticWarn = { fg = oa, bg = o1 },
    StatusLineDiagnosticInfo = { fg = ob, bg = o1 },
    StatusLineDiagnosticHint = { fg = oe, bg = o1 },

    -- Tabline
    TabLine = { fg = o4, bg = o1 },
    TabLineSel = { fg = o5, bg = o0 },
    TabLineFill = { bg = o1 },

    -- Completion menu
    Pmenu = { fg = o5, bg = o1 },
    PmenuSel = { fg = o0, bg = od },
    PmenuKind = { fg = oe, bg = o1 },
    PmenuKindSel = { fg = o0, bg = od },
    PmenuExtra = { fg = o4, bg = o1 },
    PmenuExtraSel = { fg = o0, bg = od },
    PmenuMatch = { fg = od, bg = o1, bold = true },
    PmenuMatchSel = { fg = o0, bg = od, bold = true },
    PmenuSbar = { bg = o1 },
    PmenuThumb = { bg = o3 },
    PmenuBorder = { fg = o1, bg = o1 },
    ComplMatchIns = { fg = o4 },
    WildMenu = { link = 'PmenuSel' },

    -- Diff
    Added = { fg = ob },
    Changed = { fg = oa },
    Removed = { fg = o8 },
    DiffAdd = { fg = ob, bg = '#1e221c' },
    DiffAdded = { fg = ob, bg = '#1e221c' },
    DiffChange = { fg = o4, bg = '#1f1f20' },
    DiffChangeDelete = { fg = o8, bg = '#271c1f' },
    DiffModified = { fg = o9, bg = '#28221c' },
    DiffDelete = { fg = o8, bg = '#271c1f' },
    DiffRemoved = { fg = o8, bg = '#271c1f' },
    DiffText = { fg = o5, bg = o1 },
    diffOldFile = { fg = oe },
    diffNewFile = { fg = od },

    gitcommitOverflow = { fg = o8 },
    gitcommitSummary = { fg = ob },
    gitcommitComment = { fg = o3 },
    gitcommitUntracked = { fg = o3 },
    gitcommitDiscarded = { fg = o3 },
    gitcommitSelected = { fg = o3 },
    gitcommitHeader = { fg = oe },
    gitcommitSelectedType = { fg = od },
    gitcommitUnmergedType = { fg = od },
    gitcommitDiscardedType = { fg = od },
    gitcommitBranch = { fg = o9, bold = true },
    gitcommitUntrackedFile = { fg = oa },
    gitcommitUnmergedFile = { fg = o8, bold = true },
    gitcommitDiscardedFile = { fg = o8, bold = true },
    gitcommitSelectedFile = { fg = ob, bold = true },

    -- Spell
    SpellBad = { sp = o8, undercurl = true },
    SpellCap = { sp = oa, undercurl = true },
    SpellLocal = { sp = oc, undercurl = true },
    SpellRare = { sp = oe, undercurl = true },

    -- LSP
    LspReferenceText = { bg = o2 },
    LspReferenceRead = { bg = o2 },
    LspReferenceWrite = { bg = o2 },
    LspInlayHint = { fg = o4, bg = o1 },
    LspSignatureActiveParameter = { fg = o0, bg = ob },

    DiagnosticError = { fg = o8 },
    DiagnosticWarn = { fg = oa },
    DiagnosticInfo = { fg = ob },
    DiagnosticHint = { fg = oe },
    DiagnosticOk = { fg = ob },

    DiagnosticVirtualTextError = { fg = o8, bg = '#271c1f' },
    DiagnosticVirtualTextWarn = { fg = oa, bg = '#2a251f' },
    DiagnosticVirtualTextInfo = { fg = ob, bg = '#1e221c' },
    DiagnosticVirtualTextHint = { fg = oe, bg = '#251e1f' },
    DiagnosticVirtualTextOk = { fg = ob, bg = '#1e221c' },

    DiagnosticUnderlineError = { sp = o8, undercurl = true },
    DiagnosticUnderlineWarn = { sp = oa, undercurl = true },
    DiagnosticUnderlineInfo = { sp = ob, undercurl = true },
    DiagnosticUnderlineHint = { sp = oe, undercurl = true },
    DiagnosticUnderlineOk = { sp = ob, undercurl = true },

    DiagnosticUnnecessary = { fg = o3 },
    DiagnosticDeprecated = { sp = o8, strikethrough = true },

    -- Comment keywords
    PatternTodo = { fg = o0, bg = oa, bold = true },
    PatternFixme = { fg = o0, bg = o8, bold = true },
    PatternHack = { fg = o0, bg = o9, bold = true },
    PatternNote = { fg = o0, bg = o5, bold = true },
    PatternWarn = { fg = o9, bold = true },
    PatternPerf = { fg = o0, bg = oe, bold = true },
    PatternTest = { fg = o0, bg = oe, bold = true },

    -- Treesitter
    ['@variable'] = { fg = o5 },
    ['@variable.builtin'] = { fg = o9 },
    ['@variable.parameter'] = { fg = o8 },
    ['@variable.member'] = { fg = o8 },
    ['@variable.member.key'] = { fg = o8 },

    ['@module'] = { fg = o8 },

    ['@constant'] = { fg = o9 },
    ['@constant.builtin'] = { fg = o9 },
    ['@constant.macro'] = { fg = o8 },

    ['@string'] = { fg = ob },
    ['@string.regexp'] = { fg = oc },
    ['@string.escape'] = { fg = oc },
    ['@character'] = { fg = o8 },
    ['@number'] = { fg = o9 },
    ['@number.float'] = { fg = o9 },

    ['@annotation'] = { fg = of },
    ['@attribute'] = { fg = oa },
    ['@error'] = { fg = o8 },

    ['@keyword'] = { fg = oe },
    ['@keyword.exception'] = { fg = o8 },
    ['@keyword.function'] = { fg = oe },
    ['@keyword.return'] = { fg = oe },
    ['@keyword.operator'] = { fg = oe },
    ['@keyword.import'] = { link = 'Include' },
    ['@keyword.conditional'] = { fg = oe },
    ['@keyword.conditional.ternary'] = { fg = oe },
    ['@keyword.repeat'] = { fg = oa },
    ['@keyword.storage'] = { fg = oa },
    ['@keyword.directive'] = { fg = oa },
    ['@keyword.directive.define'] = { fg = oe },

    ['@function'] = { fg = od },
    ['@function.builtin'] = { fg = od },
    ['@function.macro'] = { fg = o8 },
    ['@function.call'] = { fg = od },
    ['@function.method'] = { fg = od },
    ['@function.method.call'] = { fg = od },
    ['@constructor'] = { fg = oc },

    ['@operator'] = { fg = o5 },
    ['@reference'] = { fg = o5 },
    ['@punctuation.bracket'] = { fg = of },
    ['@punctuation.delimiter'] = { fg = of },
    ['@symbol'] = { fg = ob },
    ['@tag'] = { fg = oa },
    ['@tag.attribute'] = { fg = o8 },
    ['@tag.delimiter'] = { fg = of },
    ['@text'] = { fg = o5 },
    ['@text.emphasis'] = { fg = o9 },
    ['@text.strike'] = { fg = of, strikethrough = true },
    ['@type.builtin'] = { fg = oa },
    ['@definition'] = { sp = o4, underline = true },
    ['@scope'] = { bold = true },
    ['@property'] = { fg = o8 },

    ['@markup.heading'] = { fg = od },
    ['@markup.raw'] = { fg = o9 },
    ['@markup.link'] = { fg = o8 },
    ['@markup.link.url'] = { fg = o9, underline = true },
    ['@markup.link.label'] = { fg = oc },
    ['@markup.list'] = { fg = o8 },
    ['@markup.strong'] = { bold = true },
    ['@markup.underline'] = { underline = true },
    ['@markup.italic'] = { italic = true },
    ['@markup.strikethrough'] = { strikethrough = true },
    ['@markup.quote'] = { bg = o1 },

    ['@comment'] = { fg = o4 },
    ['@comment.todo'] = { fg = o0, bg = o5 },
    ['@comment.warning'] = { fg = o0, bg = o9 },
    ['@comment.note'] = { fg = o0, bg = od },
    ['@comment.error'] = { fg = o0, bg = o8 },

    ['@diff.plus'] = { fg = ob },
    ['@diff.minus'] = { fg = o8 },
    ['@diff.delta'] = { fg = o4 },

    -- Semantic tokens
    ['@lsp.type.comment'] = { link = 'Comment' },

    ['@lsp.type.operator'] = { fg = o5 },
    ['@lsp.type.punctuation'] = { fg = o5 },
    ['@lsp.type.variable'] = { fg = o5 },
    ['@lsp.type.attributeBracket'] = { fg = o5 },

    ['@lsp.type.macro'] = { fg = o8 },
    ['@lsp.type.formatSpecifier'] = { fg = o8 },
    ['@lsp.type.namespace'] = { fg = o8 },
    ['@lsp.type.parameter'] = { fg = o8 },
    ['@lsp.type.property'] = { fg = o8 },
    ['@lsp.type.decorator'] = { fg = o8 },
    ['@lsp.type.builtinAttribute'] = { fg = o8 },
    ['@lsp.type.generic'] = { fg = o8 },

    ['@lsp.type.boolean'] = { fg = o9 },
    ['@lsp.type.enumMember'] = { fg = o9 },
    ['@lsp.type.const'] = { fg = o9 },
    ['@lsp.type.number'] = { fg = o9 },
    ['@lsp.type.selfKeyword'] = { fg = o9 },
    ['@lsp.type.selfTypeKeyword'] = { fg = o9 },
    ['@lsp.typemod.enumMember.defaultLibrary'] = { fg = o9 },
    ['@lsp.typemod.variable.defaultLibrary'] = { fg = o9 },
    ['@lsp.typemod.variable.static'] = { fg = o9 },

    ['@lsp.type.struct'] = { fg = oa },
    ['@lsp.type.class'] = { fg = oa },
    ['@lsp.type.builtinType'] = { fg = oa },
    ['@lsp.type.deriveHelper'] = { fg = oa },
    ['@lsp.type.enum'] = { fg = oa },
    ['@lsp.type.interface'] = { fg = oa },
    ['@lsp.type.typeAlias'] = { fg = oa },
    ['@lsp.typemod.class.defaultLibrary'] = { fg = oa },
    ['@lsp.typemod.enum.defaultLibrary'] = { fg = oa },
    ['@lsp.typemod.struct.defaultLibrary'] = { fg = oa },

    ['@lsp.type.string'] = { fg = ob },

    ['@lsp.type.escapeSequence'] = { fg = oc },
    ['@lsp.type.lifetime'] = { fg = oc },

    ['@lsp.type.function'] = { fg = od },
    ['@lsp.type.method'] = { fg = od },
    ['@lsp.typemod.function.defaultLibrary'] = { fg = od },
    ['@lsp.typemod.macro.defaultLibrary'] = { fg = od },
    ['@lsp.typemod.method.defaultLibrary'] = { fg = od },
    ['@lsp.typemod.variable.callable'] = { fg = od },

    ['@lsp.type.keyword'] = { fg = oe },
    ['@lsp.typemod.keyword.async'] = { fg = oe },

    -- Gitsigns
    GitSignsAdd = { fg = ob },
    GitSignsChange = { fg = od },
    GitSignsDelete = { fg = o8 },
    GitSignsAddNr = { fg = ob },
    GitSignsChangeNr = { fg = od },
    GitSignsDeleteNr = { fg = o8 },
    GitSignsAddLn = { fg = ob },
    GitSignsDeleteLn = { fg = o8 },
    GitSignsCurrentLineBlame = { fg = o4 },

    -- mini.icons
    MiniIconsAzure = { fg = od },
    MiniIconsBlue = { fg = od },
    MiniIconsCyan = { fg = oc },
    MiniIconsGreen = { fg = ob },
    MiniIconsGrey = { fg = o4 },
    MiniIconsOrange = { fg = o9 },
    MiniIconsPurple = { fg = oe },
    MiniIconsRed = { fg = o8 },
    MiniIconsYellow = { fg = oa },

    -- Indent
    IblChar = { fg = o2 },
    IblScopeChar = { fg = o3 },
    ['@ibl.scope.underline.1'] = { bg = o1 },
    ['@ibl.scope.underline.2'] = { bg = o1 },
    ['@ibl.scope.underline.3'] = { bg = o1 },
    ['@ibl.scope.underline.4'] = { bg = o1 },
    ['@ibl.scope.underline.5'] = { bg = o1 },
    ['@ibl.scope.underline.6'] = { bg = o1 },
    ['@ibl.scope.underline.7'] = { bg = o1 },

    -- fzf-lua
    FzfLuaNormal = { fg = o5, bg = o1 },
    FzfLuaBorder = { fg = o1, bg = o1 },
    FzfLuaPrompt = { fg = o5, bg = o1 },
    FzfLuaPromptPrefix = { fg = o8, bg = o1 },
    FzfLuaPromptNormal = { fg = o5, bg = o1 },
    FzfLuaPromptBorder = { fg = o1, bg = o1 },
    FzfLuaPreviewNormal = { bg = o1 },
    FzfLuaPreviewBorder = { fg = o1, bg = o1 },
    FzfLuaPreviewTitle = { fg = o0, bg = ob },
    FzfLuaPromptTitle = { fg = o0, bg = o8 },
    FzfLuaResultsTitle = { fg = o0, bg = od },
    FzfLuaCursorLine = { fg = o5, bg = o2 },
    FzfLuaSearch = { fg = od, bg = o2 },
    FzfLuaDirIcon = { fg = od },
    FzfLuaFilePart = { fg = o5 },
    FzfLuaDirPart = { fg = o4 },
    FzfLuaFzfNormal = { fg = o5, bg = o1 },
    FzfLuaFzfCursorLine = { bg = o2 },
    FzfLuaFzfMatch = { fg = od, bold = true },
    FzfLuaFzfPrompt = { fg = o5 },
    FzfLuaFzfPointer = { fg = o2 },
    FzfLuaFzfMarker = { fg = oe },
    FzfLuaFzfSpinner = { fg = oe },
    FzfLuaFzfHeader = { fg = oe },
    FzfLuaFzfInfo = { fg = oc },
    FzfLuaFzfBorder = { fg = o1 },
    FzfLuaFzfScrollbar = { fg = o3 },
    FzfLuaFzfSeparator = { fg = o1 },
    FzfLuaFzfGutter = { bg = o1 },
    FzfLuaFzfQuery = { fg = o5 },
}

local term = { o0, o8, ob, oa, od, oe, oc, o5, o3, o8, ob, oa, od, oe, oc, o7 }
local source = (assert(debug.getinfo(1, 'S')).source):sub(2)
local dir = vim.fn.stdpath 'state' .. '/colors'

---@return string? path
local function locate()
    local stat = vim.uv.fs_stat(source)
    if not stat then return end
    return ('%s/%d-%d-%d.bin'):format(dir, stat.size, stat.mtime.sec, stat.mtime.nsec)
end

local M = {}

function M.apply()
    vim.cmd 'hi clear'
    if vim.fn.exists 'syntax_on' == 1 then vim.cmd 'syntax reset' end

    local cache = locate()

    local lines = {
        'return string.dump(function()',
        '  local h = vim.api.nvim_set_hl',
        '  local g = vim.g',
    }

    for name, spec in pairs(hl) do
        if next(spec) then
            local parts = {}
            for k, v in pairs(spec) do
                local t = type(v)
                if t == 'string' then
                    parts[#parts + 1] = k .. "='" .. v .. "'"
                elseif t == 'boolean' or t == 'number' then
                    parts[#parts + 1] = k .. '=' .. tostring(v)
                else
                    error(('colors: %s.%s is a %s, which does not survive compilation'):format(name, k, t))
                end
            end
            if #parts > 0 then lines[#lines + 1] = string.format("  h(0,'%s',{%s})", name, table.concat(parts, ',')) end
        end
    end

    for i, color in ipairs(term) do
        lines[#lines + 1] = string.format("  g.terminal_color_%d='%s'", i - 1, color)
    end

    lines[#lines + 1] = "  g.colors_name='custom'"
    lines[#lines + 1] = 'end, true)'

    local bytecode = assert(assert(loadstring(table.concat(lines, '\n'), '@colors'))())

    if cache then
        vim.fn.mkdir(dir, 'p')
        for _, stale in ipairs(vim.fn.glob(dir .. '/*.bin', true, true)) do
            if stale ~= cache then os.remove(stale) end
        end

        local file = io.open(cache, 'wb')
        if file then
            file:write(bytecode)
            file:close()
        end
    end

    assert(loadstring(bytecode))()
end

function M.setup()
    local cache = locate()
    if cache then
        local chunk = loadfile(cache)
        if chunk then return chunk() end
    end
    M.apply()
end

function M.compile()
    package.loaded['colors'] = nil
    return require('colors').apply()
end

return M
