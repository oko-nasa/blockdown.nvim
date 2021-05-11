local function BuildArray(...)
    local arr = {}
    for v in ... do
        arr[#arr + 1] = v
    end
    return arr
end

return {
    buildArray = BuildArray,
}
