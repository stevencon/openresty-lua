local httpc = require('HttpReq')
local _M = {}

function _M.checkNgx()
    -- 调用go的接口生成配置文件
    local body = httpc.checkNgx()
    Log('检测nginx文件是否正常')
    return body
end

return _M
