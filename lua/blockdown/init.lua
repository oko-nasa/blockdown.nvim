cache = "/tmp/blockdown/"

if vim.fn.finddir(cache) == "" then vim.fn.mkdir(cache) end


local setup = {

    langs = {
        python = function(fpath) return "python "..fpath..".python" end,
        lua = function(fpath) return "lua "..fpath..".lua" end,
        php = function(fpath) return "php "..fpath..".php" end,
        perl = function(fpath) return "perl "..fpath..".perl" end,
        scala = function(fpath) return "scala "..fpath..".scala" end,
        bash = function(fpath) return "bash "..fpath..".bash" end,
        javascript = function(fpath) return "node "..fpath..".javascript" end,
        c = function(fpath) return "gcc "..fpath..".c -o "..fpath..".cout && "..fpath..".cout" end,
        cpp = function(fpath) return "g++ "..fpath..".cpp -o "..fpath..".cppout && "..fpath..".cppout" end,
        go = function(fpath) return "go "..fpath..".go" end,
        rust = function(fpath) return "rustc -o "..fpath..".rsout "..fpath..".rust && "..fpath..".rsout" end,
        haskell = function(fpath) return "runhaskell "..fpath..".haskell" end,
    };

    interpreter = (function(runner)
        vim.api.nvim_command(":FloatermNew "..runner)
    end);

    repl = (function(i, e)
        for n = i,e,1 do
            vim.api.nvim_command(":"..n.."FloatermSend")
        end
    end);
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

-- local function parse_opts(i)
--     if i == nil then return nil end
--     local args = {}
--     i = i-1

--     while arg_pattern:match_line(0,i-1) ~= nil do
--         print("im here")
--         local _,_,k,v = string.find(vim.fn.getline(i), "^%[(.*)%]:(.*)")
--         args[k] = v
--         i = i-1
--     end

--     return args
-- end

local function RunBlock()
    local i,e = FindBlock()

    if i == nil then
        print("ERROR: no block found.")
        return
    end

    local lang = vim.api.nvim_exec("echo getline("..i..")[3:]", true):gsub("^[ ]+", ""):gsub("[ ]+$", "")
    i = i+1; e = e-1

    if lang:match(" repl$") ~= nil then
        setup.repl(i,e)

    elseif setup.langs[lang] ~= nil then
        local fpath = cache..vim.fn.expand("%:r")
        vim.api.nvim_command("silent! " .. i .. "," .. e .. "w! " .. fpath.."."..lang)
        setup.interpreter(setup.langs[lang](fpath))

    else
        print("ERROR: interpreter for '"..lang.."' not found.")
    end
end


return {
    setup = setup,
    run = RunBlock,
}
