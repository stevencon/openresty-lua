local systemInfo = require('UpdateSystem')
local json = require('cjson')
local mkill = require('KillMyself')

-- 认证token
JwtUtil.auth()

local reqData = systemInfo.getPostArgs()
local newdata = json.decode(reqData)
-- 判断是新增、编辑还是删除
local crud = newdata['crud']
--判断是ip还是域名
local isDomain = newdata['is_domain']
if crud == 'addOrUpdate' then
    local data
    -- 策略数据
    if isDomain then
        -- 走域名的流程
        data = systemInfo.dealHostStrategy(newdata)
    else
        -- 走ip流程
        data = systemInfo.dealStrategy(newdata)
    end
    Log('data:' .. TableUtil.TableToStr(data))
elseif crud == 'delete' then
    systemInfo.deleteStrategy(newdata)
end

--重启
mkill.reboot()

Log('strategy is update or delete successful!')
