local httpc = require('HttpReq')
local _M = {}

function _M.sendRequestSetConfigFile(data)
    -- 调用go的接口生成配置文件
    httpc.sendRequestSetConfigFile(data)
    Log('端口配置文件生成完毕')
end

return _M
