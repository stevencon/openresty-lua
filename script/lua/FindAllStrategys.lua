local redisHelper = require('redisHelper')
local json = require('cjson')

local prefix = 'strategy*'

-- 认证token
JwtUtil.auth(true)

redisHelper.Init()

local keys = redisHelper.GetKeys(prefix)
local result = {}

for i = 1, #keys do
    local res = redisHelper.get(keys[i])
    -- table.insert(result, res)
    local tmp = json.decode(res)
    if i == 1 then
        table.insert(result, '[')
    end
    table.insert(result, json.encode(tmp))
    table.insert(result, ',')
end

table.remove(result, #result)
table.insert(result, ']')

redisHelper.Close()
-- ngx.say(json.encode(result))
ngx.say(result)
