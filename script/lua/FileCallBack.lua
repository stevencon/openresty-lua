local httpc = require('HttpReq')
local _M = {}

function _M.fileCallBack()
    -- 调用go的接口生成配置文件
    local body = httpc.fileCallBack()
    Log('端口配置文件生成完毕')
    return body
end

return _M
