local Json = require('cjson')
local isExistStrategy = 0
local rewriteLogic = require('RewriteLogic')
local ReqUtil = require('ReqUtils')
local logger = require('Logger')

local httpLogPath = LogPathTable['http_log_path']

ngx.log(ngx.DEBUG, '进行rewrite规则过滤')
-- ngx.log(ngx.DEBUG, 'server_port:' .. ngx.var.server_port)
-- ngx.log(ngx.DEBUG, 'reqIp:' .. reqIp)

--http根据端口获取系统信息
local function getSystemInfoByPort(isBlack)
    local server_port = ngx.var.server_port
    local system_tmp = GetShared('system_info')
    Log('system_tmp' .. type(system_tmp))
    local system_info = Json.decode(system_tmp)
    for _, v in pairs(system_info) do
        for _, system in pairs(v) do
            if server_port == system['port'] then
                if isBlack then
                    ngx.ctx.systemTable = system['innormal_server']
                    ngx.ctx.host = system['innormal_host']
                    Log('跳转非正常url:' .. system['innormal_server'])
                else
                    ngx.ctx.systemTable = system['normal_server']
                    ngx.ctx.host = system['normal_host']
                    Log('跳转url:' .. system['normal_server'])
                end
            end
        end
    end
end

--[[检测策略是否存在]]
local function checkStrategyIsExist()
    -- 取请求ip
    local reqIp = ReqUtil.getReqIp()
    ngx.log(ngx.DEBUG, 'reqIp:' .. reqIp)
    -- 根据请求ip查询是否有该策略
    -- redisHelper.Init()
    -- local strategyIp = redisHelper.GetKey(prefix .. reqIp)
    -- redisHelper.Close()
    isExistStrategy = rewriteLogic.isExistKey()
    --[[不能用共享变量取策略，因为共享变量会过期]]
    -- local strategyIp = GetShared(reqIp)
    Log('保存日志')
    logger.log(httpLogPath, '请求的数据为：%s', 'sourceIp:' .. reqIp)
    -- if strategyIp == nil then
    -- 0：不存在 1-存在
    if isExistStrategy == 0 then
        -- 无策略，则直接转发到指定端口的正常系统
        getSystemInfoByPort(false)
        -- ngx.ctx.strategyIsExist = false
        Log('返回false')
        return false
    else
        -- ngx.ctx.strategyIsExist = true
        return true
    end
end


-- 查看上下文是否有策略，然后执行相应的操作
-- ngx.log(ngx.DEBUG, 'strategyIsExist:' .. tostring(ngx.ctx.strategyIsExist))
-- if ngx.ctx.strategyIsExist then
if checkStrategyIsExist() then
    -- if strategyIp ~= nil then
    if isExistStrategy == 1 then
        -- redisHelper.Init()
        -- local sValue = redisHelper.get(prefix .. strategyIp)
        -- redisHelper.Close()
        local sValue = rewriteLogic.getStrategy()
        if sValue ~= ngx.null then
            local strategy = Json.decode(sValue)
            if strategy ~= nil then
                -- 进行规则过滤
                local isMatch = rewriteLogic.MatchRules(strategy)
                if isMatch then
                    -- 符合规则，根据响应类型走不同的流程
                    Log('符合规则')
                    rewriteLogic.ExecuteActionByType(strategy)
                else
                    -- 不符合规则，直接跳转目标站点
                    Log('不符合规则')
                    rewriteLogic.NotMatchRule(strategy)
                end
            end
        end
    end
else
    rewriteLogic.SetRewrite()
end
