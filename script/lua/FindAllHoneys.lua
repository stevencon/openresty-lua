-- local redisHelper = require('redisHelper')
local json = require('cjson')

local prefix = 'honey*'

-- 认证token
JwtUtil.auth(true)

local function connectRedis()
    local redis = require 'resty.redis'

    --读取redis配置
    local host, pwd, port = RedisConfigTable['host'], RedisConfigTable['pwd'], RedisConfigTable['port']

    --连接redis
    local cache = redis.new()
    local ok, err = cache:connect(host, port)
    if not ok then
        ngx.log(ngx.DEBUG, 'redis connect failed' .. tostring(err))
        return
    end
    cache:set_timeouts(1000, 1000, 1000)
    if pwd ~= '' then
        local ok, err = cache:auth(pwd)
        if not ok then
            ngx.log(ngx.DEBUG, 'redis auth failed' .. tostring(err))
            return
        end
    end
    return cache
end

-- redisHelper.Init()

-- local keys = redisHelper.GetKeys(prefix)
local cache = connectRedis()
local keys = cache:keys(prefix)
local result = {}

for i = 1, #keys do
    -- local res = redisHelper.get(keys[i])
    local res = cache:get(keys[i])
    local tmp = json.decode(res)
    if i == 1 then
        table.insert(result, '[')
    end
    table.insert(result, json.encode(tmp))
    table.insert(result, ',')
    -- table.insert(result, res)
end

table.remove(result, #result)
table.insert(result, ']')
cache:close()
-- cache.Close()
-- redisHelper.Close()

-- ngx.say(json.encode(result))
ngx.say(result)
