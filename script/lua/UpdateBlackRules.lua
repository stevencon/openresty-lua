local mkill = require('KillMyself')
local systemInfo = require('UpdateSystem')

-- 黑名单ip数据
local reqData = systemInfo.getPostArgs()
systemInfo.dealBlackIp(reqData)

--重启
mkill.reboot()

ngx.say('修改黑名单ip成功')