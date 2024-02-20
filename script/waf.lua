local ReqUtil = require('ReqUtils')
local json = require('cjson')
local logger = require('Logger')
local dataProcess = require('DataProcess')
-- local redisHelper = require('redisHelper')
local _M = {}
local prefix = 'strategy_'

-- logPath = logPathTable['intercept_log_path']
local httpLogPath = LogPathTable['http_log_path']

-- -- 检测ip黑名单
-- function _M.check_black_ip()
--     local reqIp = ReqUtil.getReqIp()
--     ngx.log(ngx.DEBUG, 'reqIp:' .. reqIp)
--     local blackIp = GetShared(reqIp)

--     if blackIp ~= nil then
--         ipTable = json.decode(blackIp)
--     end

--     local port = ngx.var.server_port
--     ngx.log(ngx.DEBUG, port)
--     if blackIp == nil or ipTable['state'] == 'off' then
--         ngx.log(ngx.DEBUG, '允许的ip')
--         -- Log('允许的ip')
--         -- ngx.ctx.script = nil
--         -- ngx.ctx.ipTable = nil
--         return false
--     else
--         -- Log('黑名单的ip')
--         ngx.log(ngx.DEBUG, '黑名单的ip')
--         -- 如果规则是启动状态，则根据action做不同的处理
--         local action = ipTable['action']
--         local delayTime = ipTable['delay_time']
--         if action ~= nil then
--             --在set_by_lua中，不允许执行output api,control api,subrequest api......
--             ngx.ctx.action = action
--             if action == 'delay' then
--                 ngx.ctx.delayTime = delayTime
--             end
--         end
--         -- ngx.ctx.ipTable = ipTable
--         -- Log('执行的模块为：' .. tostring(ipTable['scriptName']))
--         -- ngx.ctx.script = RequireEx(ipTable['scriptName'], ipTable['scriptVersion'])
--         -- 记录日志
--         logRecord.log_record(logPath, ngx.var.request_uri, '_', 'blackIp')
--         ngx.log(ngx.DEBUG, '保存日志成功')
--         return true
--     end
-- end


--检查策略key是否存在
function _M.checkStrategyIsExist()
    -- 取请求ip
    local reqIp = ReqUtil.getReqIp()
    ngx.log(ngx.DEBUG, 'reqIp:' .. reqIp)
    -- 根据请求ip查询是否有该策略
    -- redisHelper.Init()
    -- local strategyIp = redisHelper.GetKey(prefix .. reqIp)
    -- redisHelper.Close()
    local strategyIp = dataProcess.getRedisKey(prefix .. reqIp)
    --[[不能用共享变量取策略，因为共享变量会过期]]
    -- local strategyIp = GetShared(reqIp)
    if strategyIp == nil then
        -- 无策略，则直接转发到指定端口的正常系统
        _M.getSystemInfoByPort(false)
        ngx.ctx.strategyIsExist = false
    else
        ngx.ctx.strategyIsExist = true
        ngx.ctx.strategyIp = strategyIp
    end
    logger.log(httpLogPath, '请求的数据为：%s', 'sourceIp:' .. reqIp)
end

--http根据端口获取系统信息
function _M.getSystemInfoByPort(isBlack)
    local server_port = ngx.var.server_port
    local system_tmp = GetShared('system_info')
    Log('system_tmp' .. type(system_tmp))
    local system_info = json.decode(system_tmp)
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
                    Log('跳转正常url:' .. system['normal_server'])
                end
            end
        end
    end
end

-- -- 总的检查入口
-- function _M.check()
--     -- 检测黑名单ip,运行相应的脚本
--     local isBlackIp = _M.check_black_ip()
--     -- local isBlackUri = _M.check_black_uri()
--     local isBlackUri = false
--     if isBlackIp then
--         _M.getSystemInfoByPort(isBlackIp)
--     elseif isBlackUri then
--         Log('uri还没写')
--     else
--         --通过规则，跳转正常系统
--         _M.getSystemInfoByPort(false)
--     end
-- end

-- 总的检查入口
function _M.check()
    _M.checkStrategyIsExist()
    -- if checkStrategyIsExist then
    --     _M.getSystemInfoByPort(isBlackIp)
    -- elseif isBlackUri then
    --     Log('uri还没写')
    -- else
    --     --通过规则，跳转正常系统
    --     _M.getSystemInfoByPort(false)
    -- end checkStrategyIsExist
end

return _M
