local redis = require('resty.redis')
local _M = {}
local red = nil

--定义连接ip,密码，端口
-- local host, pwd, port = '192.168.188.111', 'network2020', 6379
-- 本地
-- local redisConfig = fileHelper.Loadjson(readPath)
-- local host, pwd, port = redisConfig['host'], redisConfig['pwd'], redisConfig['port']
local host, pwd, port = RedisConfigTable['host'], RedisConfigTable['pwd'], RedisConfigTable['port']
-- local host, pwd, port = '127.0.0.1', 'network2020', 6379

--连接redis
function _M.Init()
    if not red then
        red = redis:new()
        -- 连接时间，发送时间，读写时间
        red:set_timeouts(1000, 1000, 1000)
        local ok, err = red:connect(host, port)
        if not ok then
            ngx.log(ngx.DEBUG, 'failed to connect:' .. tostring(err))
            return false
        end
        --验证密码
        if pwd ~= '' then
            local _, _ = red:auth(pwd)
            if not ok then
                ngx.log(ngx.DEBUG, 'redis auth failed' .. tostring(err))
                return false
            end
        end
    end
end

-- 关闭redis连接
function _M.Close()
    if not red then
        return
    end
    -- local pool_max_idle_time = 10000
    -- local pool_size = 100
    -- local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)
    -- if not ok then
    --     ngx.log(ngx.ERR, 'set keepalive error :' .. tostring(err))
    -- end
    -- ngx.log(ngx.DEBUG, 'set keepalive success' .. tostring(ok))
    ngx.log(ngx.DEBUG, tostring(red))
    red:close()
    red = nil
end

function _M.get(key)
    ngx.log(ngx.DEBUG, 'key:' .. key)
    local res, err = red:get(key)
    if not res then
        ngx.log(ngx.DEBUG, 'get data error:' .. tostring(err))
    end
    return res
end

function _M.GetList(key)
    local resp = red:smembers(key)
    return resp
end

function _M.SetList(key, value)
    ngx.log(ngx.DEBUG, 'value 11111')
    ngx.log(ngx.DEBUG, tostring(value))
    local resp = red:smembers(key, value)
    return resp
end

function _M.Set(key, value)
    local resp = red:set(key, value)
    return resp
end

function _M.Expire(key, value)
    local resp, _ = red:expire(key, value)
    return resp
end

function _M.Incr(key)
    local resp = red:incr(key)
    return resp
end

function _M.GetKeys(key)
    local resp = red:keys(key)
    return resp
end

function _M.GetKey(key)
    local resp = red:key(key)
    return resp
end

function _M.GetValues(...)
    local resp = red:mget(arg)
    return resp
end

function _M.DelKey(key)
    local resp = red:del(key)
    return resp
end

function _M.Exists(key)
    local resp = red:exists(key)
end

return _M
