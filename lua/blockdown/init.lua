local U = require"utils"
local cache = "/tmp/blockdown/"

if vim.fn.finddir(cache) == "" then vim.fn.mkdir(cache) end


local _setup = {
    langs = {
        python = function(fpath,args) return "python "..fpath..".python "..args end,
        lua = function(fpath,args) return "lua "..fpath..".lua "..args end,
        php = function(fpath,args) return "php "..fpath..".php "..args end,
        perl = function(fpath,args) return "perl "..fpath..".perl "..args end,
        scala = function(fpath,args) return "scala "..fpath..".scala "..args end,
        bash = function(fpath,args) return "bash "..fpath..".bash "..args end,
        javascript = function(fpath,args) return "node "..fpath..".javascript "..args end,
        c = function(fpath,args) return "gcc "..fpath..".c -o "..fpath..".cout && "..fpath..".cout "..args end,
        cpp = function(fpath,args) return "g++ "..fpath..".cpp -o "..fpath..".cppout && "..fpath..".cppout "..args end,
        go = function(fpath,args) return "go "..fpath..".go "..args end,
        rust = function(fpath,args) return "rustc -o "..fpath..".rsout "..fpath..".rust && "..fpath..".rsout "..args end,
        haskell = function(fpath,args) return "runhaskell "..fpath..".haskell "..args end,
    };

    interpreter = (function(runner) vim.api.nvim_command(":FloatermNew "..runner) end);

    repl = (function(i, e, name) for n = i,e,1 do vim.api.nvim_command(":"..n.."FloatermSend"..(name~=nil and (" --name="..name) or "")) end end);
}


local block_pattern = vim.regex("^```")
local function FindBlock()
    local start_line = vim.fn.line(".")-1
    local end_line = start_line
    local final_line = vim.fn.line("$")-1

    while start_line >= 0 do
        if block_pattern:match_line(0, start_line) == nil
        then start_line = start_line - 1
        else break
        end
    end
    if start_line < 0 then return nil end

    if start_line == end_line then end_line = end_line+1 end
    while end_line <= final_line do
        if block_pattern:match_line(0, end_line) == nil
            then end_line = end_line + 1
            else break
        end
    end
    if end_line > final_line or end_line == start_line then return nil end

    return start_line+1, end_line+1
end


local function GetArgsBlock(i)
    local ret = {}

    local _,_,k,v = string.find(vim.fn.getline(i), "^%[(.+)%]:(.+)")
    while v ~= nil and i > 0 do
        ret[#ret+1] = {k:gsub("^%s+", ""):gsub("%s+$", ""),v:gsub("^%s+", ""):gsub("%s+$", "")}
        i = i-1
        _,_,k,v = string.find(vim.fn.getline(i), "^%[(.+)%]:(.+)")
    end

    return ret
end


local function RunRepl(i,e,lang,name,args)

    -- for pi = 1,#args do
    --     arg = args[#args+1-pi]
    --     if arg[1] == "REPL" then
    --         return
    --     else
    --         print("ERROR: '"..arg[1].."' doesn't exist as a possible argument for executable blocks.")
    --         return
    --     end
    -- end

    print(name)
    if name ~= nil then
        vim.api.nvim_command(":FloatermNew --name="..name.." python")
    end
    _setup.repl(i, e, name)
end

local function RunInterpreter(i,e,lang,args)
    local path = cache
    local fargs = ""

    for pi = 1,#args do
        arg = args[#args+1-pi]
        if arg[1] == "DUMP" then
            path = arg[2]
        elseif arg[1] == "ARGS" then
            fargs = fargs.." "..arg[2]
        else
            print("ERROR: '"..arg[1].."' doesn't exist as a possible argument for executable blocks.")
            return
        end
    end

    local fpath = path..vim.fn.expand("%:r")
    vim.api.nvim_command("silent! " .. i .. "," .. e .. "w! " .. fpath.."."..lang)
    _setup.interpreter(_setup.langs[lang](fpath,fargs))
end


local function RunBlock()
    local i,e = FindBlock()
    if U.checkerError(
        i == nil,
        "ERROR: no block found.") then return end

    local lang = vim.api.nvim_exec("echo getline("..i..")[3:]", true):gsub("^%s+", ""):gsub("%s+$", "")
    local blockhead = {}
    lang:gsub("%w+", function(c) table.insert(blockhead,c) end)

    if U.checkerError(
        not (blockhead[2] ~= nil and blockhead[2] == "repl" or _setup.langs[lang] ~= nil),
        "ERROR: interpreter for '"..lang.."' not found.") then return end

    i = i+1; e = e-1
    local execargs = GetArgsBlock(i-2)

    if blockhead[2] ~= nil and blockhead[2] == "repl" then
        RunRepl(i,e, blockhead[1], blockhead[3], execargs)

    elseif _setup.langs[lang] ~= nil then
        RunInterpreter(i, e, lang, execargs)

    end
end


return {
    setup = _setup,
    run = RunBlock,
}
