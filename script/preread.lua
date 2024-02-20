--[[进行所有规则的匹配，方便进行后续操作]]
local json = require('cjson')
local _M = {}
local systemInfo = nil
local streamRewriteLogic = require('StreamRewriteLogic')
local prefix = 'strategy_'
local logPath = LogPathTable['tcp_log_path']
local logger = require('Logger')

-- 获取策略信息，转发tcp
local function getStragetyInfo(strategyIp)
    local cache = _M.connectRedis()
    -- redisHelper.Init()
    -- local sValue = redisHelper.get(prefix .. strategyIp)
    -- redisHelper.Close()
    local sValue = cache:get(prefix .. strategyIp)
    LogStr(sValue)
    if sValue ~= ngx.null then
        local strategy = json.decode(sValue)
        if strategy ~= nil then
            -- 规则过滤
            local isMatch = streamRewriteLogic.MatchRules(strategy)
            LogStr(isMatch: .. tostring(isMatch))
            if isMatch then
                LogStr('符合规则')
                streamRewriteLogic.ExecuteActionByType(strategy)
            else
                streamRewriteLogic.NotMatchRule(strategy)
                LogStr('不符合规则')
            end
        end
    else
        ngx.exit(505)
    end
    logger.log(logPath, '请求数据为：%s', 'sourceIp:' .. ReqUtil.tcpGetIp())
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

--检查策略key是否存在
function _M.checkStrategyIsExist()
    -- 取请求ip
    local reqIp = ReqUtil.tcpGetIp()
    ngx.log(ngx.DEBUG, 'reqIp:' .. reqIp)
    -- 根据请求ip查询是否有该策略
    local cache = _M.connectRedis()
    local isExistStrategy = cache:exists(prefix .. reqIp)
    -- redisHelper.Init()
    -- local isExistStrategy = redisHelper.Exists(prefix .. reqIp)
    -- redisHelper.Close()
    LogStr('isExistStrategy:' .. tostring(isExistStrategy))
    -- local strategyIp = GetShared(reqIp)
    if isExistStrategy == 0 then
        -- 无策略，则直接转发到指定的tcp地址
        systemInfo = GetShared('system_info')
        _M.getSystemInfoByPort()
    else
        -- 获取策略信息转发tcp
        getStragetyInfo(reqIp)
    end
end

--http根据端口获取系统信息
function _M.getSystemInfoByPort()
    local server_port = ngx.var.server_port
    local info = json.decode(systemInfo)
    if info ~= nil then
        for _, v in pairs(info) do
            for _, system in pairs(v) do
                if server_port == system['port'] then
                    ngx.log(ngx.DEBUG, '访问的目标地址:' .. system['normal_server'])
                    ngx.var.targetIp = system['normal_server']
                    ngx.var.targetPort = system['normal_port']
                end
            end
        end
    else
        LogStr('systemtmp为空')
        ngx.exit(505)
    end
end

-- 总的检查入口
function _M.check()
    -- 检测是否存在策略
    _M.checkStrategyIsExist()
end

_M.check()
