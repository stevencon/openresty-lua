local httpc = require('HttpReq')
local _M = {}

function _M.monitorPort(data)
    -- 端口监测
    local body = httpc.MonitorPort(data)
    Log('端口监测完毕')
    return body
end

return _M