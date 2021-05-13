local cache = "/tmp/blockdown/"
if vim.fn.finddir(cache) == "" then vim.fn.mkdir(cache) end

local U = require"utils"
local cmd = vim.api.nvim_command



local _setup = {

    runner = {
        _func = (function(runner, _target)
            local target = _target ~= nil and _target or "0.1"
            vim.api.nvim_command(":silent !tmux send-keys -t "..target..' "'..U.keystrokes(runner)..'" ENTER')
        end);

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

    repl = (function(i, e)
        for n = i,e,1 do cmd([[silent !tmux send-keys -t 0.1 "]]..U.keystrokes(vim.fn.getline(n))..[[" ENTER]]) end
    end);

}

--[[
    FindBlock() catches the lines which delimit a codeblock.
--]]
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


--[[
    GetArgsBlock(i) fetches all [ARGS]: starting from i upwards.
--]]
local function GetArgsBlock(i)
    local ret = {}

    local _,_,k,v = vim.fn.getline(i):find("^%[(.+)%]:(.*)")
    while v ~= nil and i > 0 do
        ret[#ret+1] = {U.trim(k), U.trim(v)}
        i = i-1
        _,_,k,v = vim.fn.getline(i):find("^%[(.+)%]:(.*)")
    end

    return ret
end


--[[
    GetArgsBlock(i) fetches all [ARGS]: starting from i upwards.
--]]
local function RunInterpreter(i,e,lang,head,args)
    local defargs = {
        path = cache,
        fargs = "",
        precmds = {},
        postcmds = {}
    }

    for _,arg in U.revpairs(args) do
        if arg[1] == "DUMP" then
            defargs.path = arg[2]

        elseif arg[1] == "ARGS" then
            defargs.fargs = defargs.fargs.." "..arg[2]

        elseif arg[1] == "CLEAR" and defargs.clear == nil then
            defargs.clear = "clear && "

        elseif arg[1] == "NAME" then
            defargs.name = arg[2]

        elseif arg[1] == "PRE" or arg[1] == "POST" then
            local key = arg[1]:lower().."cmds"
            defargs[key][#(defargs[key])+1] = arg[2]

        else
            print("ERROR: '"..arg[1].."' doesn't exist as a possible argument for executable blocks.")
            return
        end
    end

    local fpath = defargs.path..(defargs.name ~= nil and defargs.name:gsub(" ", "_") or vim.fn.expand("%:r"))
    local tmux_cmd = function(keystrokes) vim.api.nvim_command("silent! !tmux send-keys -t"..(head ~= nil and head or "0.1")..' "'..U.keystrokes(keystrokes)..'" ENTER') end

    vim.api.nvim_command("silent! " .. i .. "," .. e .. "w! " .. fpath.."."..lang)
    if defargs.clear ~= nil then tmux_cmd("clear") end

    for _,precmd in ipairs(defargs.precmds) do tmux_cmd(precmd) end
    _setup.runner._func(_setup.runner[lang](fpath,defargs.fargs), head)
    for _,postcmd in ipairs(defargs.postcmds) do tmux_cmd(postcmd) end
end


local function RunBlock()
    local i,e = FindBlock()
    if U.checkerError(
        i == nil,
        "ERROR: no block found.") then return end

    local lang = vim.api.nvim_exec("echo getline("..i..")[3:]", true):gsub("^%s+", ""):gsub("%s+$", "")
    local blockhead = {}
    lang:gsub("[%S]+", function(c) table.insert(blockhead,c) end)

    if U.checkerError(
        not (blockhead[2] ~= nil and blockhead[2] == "repl" or blockhead[1] ~= "_func" and _setup.runner[blockhead[1]] ~= nil),
        "ERROR: interpreter for '"..lang.."' not found.") then return end

    i = i+1; e = e-1
    local execargs = GetArgsBlock(i-2)

    if blockhead[2] ~= nil and blockhead[2] == "repl" then
        _setup.repl(i,e,blockhead[3])
    else
        RunInterpreter(i, e, blockhead[1], blockhead[2], execargs)
    end
end


return {
    setup = _setup,
    run = RunBlock,
}
