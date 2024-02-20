local Json = require('cjson')
local redisHelper = require('redisHelper')
local _M = {}
-- local uri_dict = ngx_shared.uri_dict

-- 数据初始化获取,设置全局变量
function _M.ruleInit(keyName, rules)
    -- local ruleTable = Json.decode(rules)
    Log('ruletable_process:' .. type(rules))
    local key
    for i, rule in pairs(rules) do
        for k, v in pairs(rule) do
            key = k
            local _, _, _ = SetShared(key, Json.encode(v), 0)
        end
    end
end

-- 数据初始化,以键存键
function _M.dataInit(keyName, datas)
    SetShared(keyName, Json.encode(datas), 0)
    -- SetShared(keyName, datas, 0)
end

function _M.stragetyInit(strategys)
    for i = 1, #strategys do
        local strategyIpArrays = StrUtil.Split(strategys[i], 'strategy_')
        local strategyIp = strategyIpArrays[2]
        ngx.log(ngx.DEBUG, 'strategyIp_init:' .. strategyIp)
        SetShared(strategyIp, strategyIp, 0)
    end
end

-- local v = GetShared(system_info)
-- ngx.log(ngx.DEBUG,v)

function _M.dataInitConfig(key, rules)
    SetShared(key, Json.encode(rules), 0)
end

-- local v = GetShared('127.0.0.1')
-- Log(v)

-- 更新规则
function _M.dataParse(data)
    local jsonTable = Json.decode(data)
    if jsonTable == nil then
        return false, 508, '无法解析'
    end

    -- if action == 'updateRules' then
    --     local newScripts = jsonTable['scripts']
    --     if newScripts ~= ngx.null then
    --         UpgradeScripts(newScripts)
    --     end

    --     local newAccounts = jsonTable['accounts']
    --     if newAccounts ~= ngx.null then
    --         _M.UpgradeAccounts(newAccounts)
    --         MyRedis.Init()
    --         MyRedis.Set('accounts', Json.encode(newAccounts))
    --         MyRedis.Close()
    --     end
    --     return true, 200, 'success'
    -- else
    --     return false, 588, '错误的调用'
    -- end
end

-- 初始化redis数据，用于测试
function _M.setRedis(keyName, data)
    redisHelper.Init()
    redisHelper.Set(keyName, data)
    redisHelper.Close()
    return true, 200, 'success'
end

--更新时读取数据
function _M.getRedisData(keyname)
    redisHelper.Init()
    local data = redisHelper.get(keyname)
    redisHelper.Close()
    return data
end

-- 删除指定key数据
function _M.deleteRedisData(keyname)
    redisHelper.Init()
    redisHelper.DelKey(keyname)
    redisHelper.Close()
end

--设置过期时间
function _M.setRedisExpire(key, time)
    redisHelper.Init()
    redisHelper.Expire(key, time)
    redisHelper.Close()
end

--获取指定key
function _M.getRedisKey(key)
    redisHelper.Init()
    redisHelper.GetKey(key)
    redisHelper.Close()
end

return _M
