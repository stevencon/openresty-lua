local httpc = require('HttpReq')
local _M = {}

function _M.reboot()
    httpc.KillMyself()
    Log('重启成功')
end

return _M
