Redis = require 'redisHelper'
local json = require 'cjson'
local keyPrefixs = 'strategy*'
local uuid = require('resty.jit-uuid')

-- 定时器，用于读取redis的规则
local delay = 1
local handler
handler = function()
    local dataProcess = require('DataProcess')
    -- do some routine job in Lua just like a cron job
    Redis.Init()
    --取data数据
    local data = Redis.get('data')
    --取go端的ip，用于调用go
    local goIp = Redis.get('go_ip')
    -- 读取策略keys
    local strategys = Redis.GetKeys(keyPrefixs)
    Redis.Close()
    local dataJ = nil
    if data ~= ngx.null then
        dataJ = json.decode(data)
        --系统信息
        local systemInfo = dataJ['system_info']
        -- dataProcess.ruleInit('black_ip', blackIp)
        dataProcess.dataInit('system_info', systemInfo)
    end
    --黑名单
    -- local blackIp = dataJ['black_ip']
    -- Log('blackIp_worker:' .. type(blackIp))
    dataProcess.stragetyInit(strategys)

    SetShared('go_ip', goIp, 0)
    --uuid播种
    uuid.seed()
    Log('初始化redis规则完成')
    -- dataProcess.dataInitConfig('uri_rules', uri)
end

ngx.timer.at(delay, handler)

-- ngx.log(ngx.DEBUG, 'work_id: ' .. ngx.worker.id())
-- ngx.log(ngx.DEBUG, GetShared('test'))
-- DelShared('test')
-- SetShared('test', 'it is a nice dog!')
-- ngx.log(ngx.DEBUG, GetShared('test'))
-- DelShared('test')
-- ngx.log(ngx.DEBUG, GetShared('test'))
