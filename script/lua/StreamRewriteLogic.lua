local reqUtil = require('ReqUtils')
local reqIp = reqUtil.tcpGetIp()
local redisHelper = require('redisHelper')
local honeyPrefix = 'honey_'
local Json = require('cjson')
local strategyIp = ngx.ctx.strategyIp
local _M = {}

-- 不符合规则直接跳转目标站点
function _M.NotMatchRule(strategy)
    -- 根据策略的目标站点id获取目标站点，转发
    local system_tmp = GetShared('system_info')
    local system_info = Json.decode(system_tmp)
    local isExistSystem = false
    for _, v in pairs(system_info) do
        for _, system in pairs(v) do
            if strategy['system_id'] == system['id'] then
                isExistSystem = true
                ngx.var.targetIp = system['normal_server']
                LogStr('finally_ip:' .. system['normal_server'])
                ngx.var.targetPort = system['normal_port']
                LogStr('finally_port:' .. system['normal_port'])
                break
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
            local honeyTable = Json.decode(honeyValue)
            if honeyTable ~= nil then
                local ip = honeyTable['url']
                local port = honeyTable['port']
                ngx.var.targetIp = ip
                LogStr('finally_ip:' .. ip)
                ngx.var.targetPort = port
                LogStr('finally_port:' .. port)
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
        LogStr('request deny')
        --延时
        _M.Delay(isDelay, delayTime)
        ngx.exit(503)
    elseif action == 'redirect' then
        ngx.var.targetIp = strategy['redirect_server']
        LogStr('finally_ip:' .. strategy['redirect_server'])
        ngx.var.targetPort = strategy['redirect_port']
        LogStr('finally_port:' .. strategy['redirect_port'])
        --延时
        _M.Delay(isDelay, delayTime)
    end
end

-- 延时处理
function _M.Delay(isDelay, delayTime)
    -- 查看是否延迟
    if isDelay == 'on' then
        if delayTime ~= nil then
            LogStr('延迟' .. delayTime .. '秒')
            ngx.sleep(delayTime)
        else
            LogStr('延迟系统默认时间：10秒')
            ngx.sleep(10)
        end
    end
end

-- 匹配规则
function _M.MatchRules(strategy)
    --比较请求ip和端口是否符合规则
    -- if reqIp ~= strategyIp then
    --     return false
    -- end
    if ngx.var.server_port ~= strategy['port_rule'] then
        return false
    end
    return true
end

-- 无策略，直接设置重定向url
function _M.SetRewrite()
    ngx.var.rewrite_url = ngx.ctx.systemTable
    LogStr('finally_url:' .. ngx.var.rewrite_url)
    ngx.var.route_host = ngx.ctx.host
    LogStr('finally_host:' .. ngx.var.route_host)
end

return _M
