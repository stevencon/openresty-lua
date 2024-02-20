local util = {}
local cjson_safe = require 'cjson.safe'

-- 日志记录log_name
function util.FileWrite(log_name, data)
    local file, err = io.open(log_name, 'a+')
    if err ~= nil then
        ngx.log(ngx.DEBUG, 'file err:' .. err)
    end
    if file == nil then
        return
    end
    -- file:write(string.format('%s\n', data), 'a+')
    file:write(string.format('%s\n', data))
    file:flush()
    file:close()
end

--- 读取文件（全部读取/按行读取）默认 全部读取
function util.Readfile(_filepath, _ty)
    local fd, _ = io.open(_filepath, 'r')
    if not fd then
        return
    end
    if not _ty then
        local str = fd:read('*a') --- 全部内容读取
        fd:close()
        return str
    else
        local line_s = {}
        for line in fd:lines() do
            table.insert(line_s, line)
        end
        fd:close()
        return line_s
    end
end

function util.delFile(_filename)
    os.remove(_filename)
end

-- 字符串转成序列化后的json同时也可当table类型
local function stringTojson(_obj)
    local json = cjson_safe.decode(_obj)
    return json
end

function util.Loadjson(_path_name)
    local x = util.Readfile(_path_name)
    local json = stringTojson(x) or {}
    return json
end

return util
