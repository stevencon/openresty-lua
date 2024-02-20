local redisHelper = require('redisHelper')
local json = require('cjson')

-- 认证token
JwtUtil.auth(true)

redisHelper.Init()

local data = redisHelper.get('data')
if data == nil or data == ngx.null then
   ngx.exit(505)
end
local dataTable = json.decode(data)
local systemInfo = dataTable['system_info']

redisHelper.Close()

ngx.say(json.encode(systemInfo['data']))
