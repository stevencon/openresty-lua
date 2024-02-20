local ReqUtil = require('ReqUtils')
local json = require('cjson')
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

local reqIp = ReqUtil.getReqIp()
ngx.log(ngx.DEBUG, 'reqIp:' .. reqIp)
local blackIp = GetShared(reqIp)

if blackIp == nil then
    return
end

local ipTable = json.decode(blackIp)

-- 禁ip时间
local ip_bind_time = ipTable['bind_time']
if ip_bind_time == nil then
    ip_bind_time = 30
end
-- 禁ip时间范围
local ip_time_out = ipTable['time_out']
if ip_time_out == nil then
    ip_time_out = 60
end
-- ip访问次数设置
local connect_count = ipTable['connect_count']
if connect_count == nil then
    connect_count = 10
end

local is_bind = cache:get('bind_' .. reqIp)

-- 若ip被禁，则直接返回
if is_bind ~= nil and is_bind == '1' then
    ngx.log(ngx.DEBUG, 'ip_' .. reqIp .. '已被封禁,' .. '请' .. ip_bind_time .. '秒后再试！')
    ngx.exit(510)
    goto Lastend
end

start_time = cache:get('time_' .. reqIp)
ip_count = cache:get('count_' .. reqIp)
--[[
如果ip记录时间大于指定时间间隔或者记录时间或者不存在ip时间key则重置时间key和计数key
如果ip时间key小于时间间隔，则ip计数+1，且如果ip计数大于ip频率计数，则设置ip的封禁key为1
同时设置封禁key的过期时间为封禁ip的时间
]]
if start_time == ngx.null or os.time() - start_time > ip_time_out then
    cache:set('time_' .. reqIp, os.time())
    cache:set('count_' .. reqIp, 1)
else
    ngx.log(ngx.DEBUG, 'ipcount:' .. tostring(ip_count))
    ip_count = ip_count + 1
    cache:Incr('count_' .. reqIp)
    if ip_count >= connect_count then
        cache:set('bind_' .. reqIp, 1)
        cache:expire('bind_' .. reqIp, ip_bind_time)
    end
end
::Lastend::
cache:close()
