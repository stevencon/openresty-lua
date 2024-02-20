Redis = require 'redisHelper'
local keyPrefixs = 'strategy*'
local json = require('cjson')
local uuid = require('resty.jit-uuid')
ReqUtil = require('ReqUtils')

-- 定时器，用于读取redis的规则
local delay = 1
local handler
handler = function()
    local dataProcess = require('DataProcess')
    Redis.Init()
    --取data数据
    local data = Redis.get('data')
    --取go端的ip，用于调用go
    local goIp = Redis.get('go_ip')
    -- 读取策略keys
    local strategys = Redis.GetKeys(keyPrefixs)
    Redis.Close()
    if data ~= ngx.null then
        local dataJ = json.decode(data)
        --系统信息
        local systemInfo = dataJ['system_info']
        dataProcess.dataInit('system_info', systemInfo)
    end

    dataProcess.stragetyInit(strategys)
    SetShared('go_ip', goIp, 0)
    --uuid播种
    uuid.seed()
    LogStr('初始化stream redis规则完成')
    -- dataProcess.dataInitConfig('uri_rules', uri)
    -- local dataProcess = require('DataProcess')
    -- -- do some routine job in Lua just like a cron job
    -- Redis.Init()
    -- -- -- 黑名单
    -- -- local blackIp = Redis.get('black_ip')
    -- -- -- 读取系统信息
    -- local systemInfo = Redis.get('system_info')
    -- -- 读取策略keys
    -- local strategys = Redis.GetKeys(keyPrefixs)
    -- Redis.Close()
    -- -- dataProcess.ruleInit('black_ip', blackIp)
    -- dataProcess.stragetyInit(strategys)
    -- dataProcess.dataInit('system_info', systemInfo)
    -- Log('初始化redis规则完成')
end

ngx.timer.at(delay, handler)
