local _M = {}

function _M.IsStrInclude(src, ...)
    local ret = false
    for i, v in ipairs({...}) do
        v = tostring(v)
        ngx.log(ngx.DEBUG, v)
        ret = string.find(tostring(src), v) ~= nil
        if ret then
            return ret
        end
    end
    return ret
end

-- function _M.StrSplit(str, strchar)
--     local _, param = string.find(str, strchar)
--     local m = string.len(str) - param + 1
--     local result = string.sub(str, m + 1, string.len(str))
--     result = string.sub(str, m, string.len(str))
--     return result
-- end

function _M.Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

return _M
