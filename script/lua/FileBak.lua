local httpc = require('HttpReq')
local _M = {}

function _M.fileCopy()
    -- 配置文件备份
    httpc.FileCopy()
    Log('配置文件备份成功')
end

return _M