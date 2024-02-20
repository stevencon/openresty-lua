local reqUtil = require('ReqUtils')
local reqIp = reqUtil.getReqIp()
local reqHost = reqUtil.get_host()
local redisHelper = require('redisHelper')
local honeyPrefix = 'honey_'
local prefix = 'strategy_'
local Json = require('cjson')
local strategyIp = reqIp
local strategyHost = reqHost
local _M = {}

-- 不符合规则直接跳转目标站点
function _M.NotMatchRule(strategy)
    -- 根据策略的目标站点id获取目标站点，转发
    local system_tmp = GetShared('system_info')
    if system_tmp == nil then
        return
    end
    local system_info = Json.decode(system_tmp)
    local isExistSystem = true
    for _, v in pairs(system_info) do
        for _, system in pairs(v) do
            if strategy['system_id'] == system['id'] then
                ngx.var.rewrite_url = system['normal_server']
                Log('finally_url:' .. ngx.var.rewrite_url)
                ngx.var.route_host = system['normal_host']
                Log('finally_host:' .. ngx.var.route_host)
                isExistSystem = true
                break
            else
                isExistSystem = false
            end
        end
    end
    if not isExistSystem then
        ngx.exit(505)
    end
end

-- 根据策略设置的类型，执行相应操作
function _M.ExecuteActionByType(strategy)
    local action = strategy['action']
    local isDelay = strategy['is_delay']
    local delayTime = strategy['delay_time']
    if action == 'traction' then
        -- 根据目标站点id查循目标站点
        local honeyId = nil
        local system_tmp = GetShared('system_info')
        local system_info = Json.decode(system_tmp)
        for _, v in pairs(system_info) do
            for _, system in pairs(v) do
                if strategy['system_id'] == system['id'] then
                    honeyId = system['honey_id']
                    break
                end
            end
        end
        if honeyId ~= nil then
            -- 根据蜜罐id查找蜜罐配置
            redisHelper.Init()
            local honeyValue = redisHelper.get(honeyPrefix .. honeyId)
            redisHelper.Close()
            if honeyValue == ngx.null then
                ngx.exit(505)
            end
            local honeyTable = Json.decode(honeyValue)
            if honeyTable ~= nil then
                local url = honeyTable['url']
                local host = honeyTable['host']
                local port = honeyTable['port']
                -- if port ~= nil then
                --     ngx.var.rewrite_url = url .. ':' .. port
                --     Log('finally_url:' .. ngx.var.rewrite_url)
                -- else
                --     ngx.var.rewrite_url = url
                --     Log('finally_url:' .. url)
                -- end
                ngx.var.rewrite_url = url
                Log('finally_url:' .. url)
                ngx.var.route_host = host
                Log('finally_host:' .. host)
            else
                -- 自定义页面
                ngx.exit(505)
            end
            --延时
            _M.Delay(isDelay, delayTime)
        else
            ngx.say('不存在该目标站点')
        end
    elseif action == 'deny' then
        Log('request deny')
        --延时
        _M.Delay(isDelay, delayTime)
        ngx.exit(503)
    elseif action == 'redirect' then
        ngx.var.rewrite_url = strategy['redirect_server']
        Log('finally_url:' .. ngx.var.rewrite_url)
        ngx.var.route_host = strategy['redirect_host']
        Log('finally_host:' .. ngx.var.route_host)
        --延时
        _M.Delay(isDelay, delayTime)
    end
end

-- 延时处理
function _M.Delay(isDelay, delayTime)
    -- 查看是否延迟
    if isDelay == 'on' then
        if delayTime ~= nil then
            Log('延迟' .. delayTime .. '秒')
            ngx.sleep(delayTime)
        else
            Log('延迟系统默认时间：10秒')
            ngx.sleep(10)
        end
    end
end

-- 匹配规则
function _M.MatchRules(strategy)
    --比较请求ip和端口是否符合规则
    if reqIp ~= strategyIp then
        return false
    end
    if ngx.var.server_port ~= strategy['port_rule'] then
        return false
    end
    return true
end

-- 匹配域名规则
function _M.MatchHostRules(strategy)
    --比较请求ip和端口是否符合规则
    if reqHost ~= strategyHost then
        return false
    end
    if ngx.var.server_port ~= strategy['port_rule'] then
        return false
    end
    return true
end

-- 无策略，直接设置重定向url
function _M.SetRewrite()
    ngx.var.rewrite_url = ngx.ctx.systemTable
    if ngx.var.rewrite_url == nil then
        ngx.exit(505)
    end
    Log('finally_url:' .. ngx.var.rewrite_url)
    ngx.var.route_host = ngx.ctx.host
    Log('finally_host:' .. ngx.var.route_host)
end

function _M.connectRedis()
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

--获取策略
function _M.getStrategy()
    local cache = _M.connectRedis()
    Log(vvvvv: .. prefix .. strategyIp)
    local sValue = cache:get(prefix .. strategyIp)
    cache:close()
    return sValue
    -- redisHelper.Init()
    -- Log('strategyI111111p:' .. prefix .. strategyIp)
    -- local sValue = redisHelper.get(prefix .. strategyIp)
    -- redisHelper.Close()
    -- return sValue
end

--获取Host策略
function _M.getHostStrategy()
    local cache = _M.connectRedis()
    Log(vvvvv: .. prefix .. strategyHost)
    local sValue = cache:get(prefix .. strategyHost)
    cache:close()
    return sValue
    -- redisHelper.Init()
    -- Log('strategyI111111p:' .. prefix .. strategyIp)
    -- local sValue = redisHelper.get(prefix .. strategyIp)
    -- redisHelper.Close()
    -- return sValue
end

function _M.isExistKey()
    local cache = _M.connectRedis()
    local result = cache:exists(prefix .. reqIp)
    cache:close();
    Log('result:' .. tostring(result))
    -- result:0-不存在 1-存在
    return result
end

function _M.isExistHostKey()
    local cache = _M.connectRedis()
    local result = cache:exists(prefix .. reqHost)
    cache:close()
    Log('result:' .. tostring(result))
    -- result:0-不存在 1-存在
    return result
end


return _M
