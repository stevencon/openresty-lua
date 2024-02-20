local dataProcess = require('DataProcess')

if ngx.req.get_method() ~= 'POST' then
    ngx.say('请求错误')
    ngx.exit(581)
end

ngx.req.read_body()
local data = ngx.req.get_body_data()
if data == nil then
    ngx.say('数据读取失败')
    ngx.status = 580
    return
end

local _, status, msg = dataProcess.setRedis(data)

ngx.say(msg)
ngx.exit(status)


-- todo 修改规则
-- local _, status, msg = dataProcess.DataParse(data)

-- ngx.say(msg)
-- ngx.exit(status)
