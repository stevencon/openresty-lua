local systemInfo = require('UpdateSystem')
local json = require('cjson')

-- 认证token
JwtUtil.auth()

local reqData = systemInfo.getPostArgs()
local newdata = json.decode(reqData)
-- 新增，编辑或删除
local action = newdata['action']
if action == 'addOrUpdate' then
    -- 策略数据
    local data = systemInfo.dealHoney(newdata)
    Log('data:' .. TableUtil.TableToStr(data))
elseif action == 'delete' then
    systemInfo.deleteHoney(newdata)
end
