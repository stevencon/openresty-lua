local _M = {}

function _M.ToStringEx(value)
    if type(value) == 'table' then
        return _M.TableToStr(value)
    elseif type(value) == 'string' then
        return ' .. value .. '
    else
        return tostring(value)
    end
end

--Table To String

function _M.TableToStr(t)
    if t == nil then
        return ''
    end
    local retstr = '{'

    local i = 1
    for key, value in pairs(t) do
        local signal = ','
        if i == 1 then
            signal = ''
        end

        if key == i then
            retstr = retstr .. signal .. _M.ToStringEx(value)
        else
            if type(key) == 'number' or type(key) == 'string' then
                retstr = retstr .. signal .. '[' .. _M.ToStringEx(key) .. ']=' .. _M.ToStringEx(value)
            else
                if type(key) == 'userdata' then
                    retstr =
                        retstr ..
                        signal .. '*s' .. _M.TableToStr(getmetatable(key)) .. '*e' .. '=' .. _M.ToStringEx(value)
                else
                    retstr = retstr .. signal .. key .. '=' .. _M.ToStringEx(value)
                end
            end
        end

        i = i + 1
    end

    retstr = retstr .. '}'
    return retstr
end

function _M.Table_leng(t)
    local leng = 0
    for k, v in pairs(t) do
        leng = leng + 1
    end
    return leng
end

function _M.TableClone(tb)
    return {table.unpack(tb)}
end

return _M
