
local M = {}

M.checkerError = function(cond, err)
    if cond then
        print(err)
    end
    return cond
end

M.keystrokes = function(text)
    return text:gsub("\"", "\\\""):gsub(";","\\;")
end

M.trim = function(text)
    return text:gsub("^%s+", ""):gsub("%s+$", "")
end

M.revpairs = function(table)
    local i = #table+1
    return function()
        i = i - 1
        if table[i] ~= nil then return i,table[i] end
    end
end

return M
