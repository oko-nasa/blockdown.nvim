
local function checkerError(cond, err)
    if cond then
        print(err)
    end
    return cond
end


return {
    checkerError = checkerError,
}
