local dataProcess = require('DataProcess')
local json = require('cjson')
local uuid = require('resty.jit-uuid')
local logRecord = require('LogRecord')
local prefix = 'strategy_'
local honeyPrefix = 'honey_'
local _M = {}
local logPath = LogPathTable['update_system_log_path']

function _M.SaveOrUpdateBlackIps(newBlackIps, oldBlackIps)
    Log('进来了blackip')
    -- 获取历史数据的所有ip
    local oldIps = {}
    for _, v in pairs(oldBlackIps) do
        for old, _ in pairs(v) do
            table.insert(oldIps, old)
        end
    end
    local oldIpStr = TableUtil.TableToStr(oldIps)

    for _, i in pairs(newBlackIps) do
        for k, new_black in pairs(i) do
            if string.find(oldIpStr, k) == nil then
                Log('新增黑名单ip：' .. k)
                local d = {
                    ['state'] = new_black['state'],
                    ['action'] = new_black['action'],
                    ['delay_time'] = new_black['delay_time'],
                    ['bind_time'] = new_black['bind_time'],
                    ['time_out'] = new_black['time_out'],
                    ['connect_count'] = new_black['connect_count']
                }
                local newDataTable = {
                    [k] = d
                }
                table.insert(oldBlackIps, newDataTable)
            end
            for _, j in pairs(oldBlackIps) do
                for k2, old_black in pairs(j) do
                    Log('k2:' .. k2)
                    if k == k2 then
                        --更新
                        Log('更新黑名单ip：' .. k)
                        old_black['state'] = new_black['state']
                        old_black['action'] = new_black['action']
                        old_black['delay_time'] = new_black['delay_time']
                        old_black['bind_time'] = new_black['bind_time']
                        old_black['time_out'] = new_black['time_out']
                        old_black['connect_count'] = new_black['connect_count']
                        break
                    end
                end
            end
        end
    end
    return oldBlackIps
end

function _M.SaveOrUpdateSystemInfo(newSystemInfo, oldSystemInfo)
    Log('进来了system')

    -- 获取历史数据的所有port
    local oldPorts = {}
    for _, v in pairs(oldSystemInfo) do
        for _, old in pairs(v) do
            table.insert(oldPorts, old['port'])
        end
    end

    local oldPortStr = TableUtil.TableToStr(oldPorts)
    --取数据，更新或新增
    for _, v in pairs(newSystemInfo) do
        for _, new_system in pairs(v) do
            local newPort = new_system['port']
            for _, oldData in pairs(oldSystemInfo) do
                for _, old_system in pairs(oldData) do
                    if newPort == old_system['port'] then
                        --更新
                        Log('更新端口：' .. newPort)
                        local newId = new_system['id']
                        if newId == nil then
                            goto continue
                        end
                        old_system['id'] = newId
                        old_system['normal_server'] = new_system['normal_server']
                        old_system['normal_port'] = new_system['normal_port']
                        old_system['normal_host'] = new_system['normal_host']
                        old_system['protocol'] = new_system['protocol']
                        old_system['type'] = new_system['type']
                        old_system['name'] = new_system['name']
                        old_system['honey_id'] = new_system['honey_id']
                        break
                    elseif string.find(oldPortStr, newPort) == nil then
                        Log('新增端口：' .. newPort)
                        local newId = uuid()
                        newId = tostring(newId).gsub(newId, '-', '')
                        local newDataTable = {
                            ['id'] = newId,
                            ['port'] = newPort,
                            ['normal_server'] = new_system['normal_server'],
                            ['normal_host'] = new_system['normal_host'],
                            ['normal_port'] = new_system['normal_port'],
                            ['protocol'] = new_system['protocol'],
                            ['type'] = new_system['type'],
                            ['name'] = new_system['name'],
                            ['honey_id'] = new_system['honey_id']
                        }
                        table.insert(oldData, newDataTable)
                        break
                    end
                    ::continue::
                end
            end
        end
    end
    return oldSystemInfo
end

function _M.DelSystemById(newSystemInfo, oldSystemInfo)
    Log('删除目标站点')
    for _, v in pairs(newSystemInfo) do
        for _, new_system in pairs(v) do
            local newId = new_system['id']
            for _, oldData in pairs(oldSystemInfo) do
                for i = 1, #oldData do
                    local oldId = oldData[i]['id']
                    if newId == oldId then
                        Log('i:' .. tostring(i))
                        Log('delete_id:' .. newId)
                        table.remove(oldData, i)
                        break
                    end
                end
            end
        end
    end
    return oldSystemInfo
end

function _M.getPostArgs()
    Log('新增或更新')
    if ngx.req.get_method() ~= 'POST' then
        ngx.say('请求错误')
        ngx.exit(510)
    end

    ngx.req.read_body()
    local data = ngx.req.get_body_data()
    if data == nil then
        ngx.say('数据读取失败')
        ngx.status = 580
        return
    end
    return data
end

function _M.dealSystemInfo(data)
    local oldDataFullStr = dataProcess.getRedisData('data')
    local dataTable = nil
    local oldSystemInfo = nil
    if oldDataFullStr ~= ngx.null then
        dataTable = json.decode(oldDataFullStr)
        oldSystemInfo = dataTable['system_info']
    end

    local dataNewSystem = nil
    if dataTable == nil or oldSystemInfo == nil or #oldSystemInfo['data'] == 0 then
        Log('dataTable是空的')
        local dataTableTmp = json.decode(data)
        local dataTmp = dataTableTmp['system_info']['data']
        for _, v in pairs(dataTmp) do
            v['id'] = uuid()
            v['id'] = tostring(v['id']).gsub(v['id'], '-', '')
        end
        dataTableTmp['system_info']['data'] = dataTmp
        dataProcess.setRedis('data', json.encode(dataTableTmp))
        return dataTableTmp
    end

    local newData = json.decode(data)
    local action = newData['action']
    local newSystemInfo = newData['system_info']
    if action == 'updateDrainage' then
        if newSystemInfo ~= nil then
            dataNewSystem = _M.SaveOrUpdateSystemInfo(newSystemInfo, oldSystemInfo)
        end
    elseif action == 'delDrainage' then
        dataNewSystem = _M.DelSystemById(newSystemInfo, oldSystemInfo)
    -- dataNewSystem = _M.DelSystemInfo(newSystemInfo, oldSystemInfo)
    end
    -- 将系统信息更新到data
    dataTable['system_info'] = dataNewSystem
    dataProcess.setRedis('data', json.encode(dataTable))
    -- 记录更新日志
    logRecord.log_record(logPath, ngx.var.request_uri, TableUtil.TableToStr(dataNewSystem), 'saveOrupdateSystemInfo')
    ngx.log(ngx.DEBUG, '保存系统信息日志成功')
    return dataNewSystem
end

function _M.dealBlackIp(data)
    local oldDataFullStr = dataProcess.getRedisData('data')
    local dataTable = json.decode(oldDataFullStr)
    local oldBlackIps = dataTable['black_ip']

    if dataTable == nil then
        Log('dataTable是空的')
        dataProcess.setRedis('data', data)
        return
    end
    local dataNewBlack = nil
    local newData = json.decode(data)
    local action = newData['action']
    if action == 'updateRules' then
        local newBlackIps = newData['black_ip']
        if newBlackIps ~= nil then
            dataNewBlack = _M.SaveOrUpdateBlackIps(newBlackIps, oldBlackIps)
        end
    end
    dataTable['black_ip'] = dataNewBlack
    dataProcess.setRedis('data', json.encode(dataTable))
end

-- 全量data
-- function _M.getPostArgs()
--     Log('新增或更新引流策略')
--     if ngx.req.get_method() ~= 'POST' then
--         ngx.say('请求错误')
--         ngx.exit(581)
--     end

--     ngx.req.read_body()
--     local data = ngx.req.get_body_data()
--     if data == nil then
--         ngx.say('数据读取失败')
--         ngx.status = 580
--         return
--     end

--     local oldDataFullStr = dataProcess.getRedisData('data')
--     local dataTable = json.decode(oldDataFullStr)
--     local oldSystemInfo = dataTable['system_info']
--     local oldBlackIps = dataTable['black_ip']

--     local dataNewSystem = {}
--     if dataTable == nil then
--         Log('dataTable是空的')
--         dataProcess.setRedis('data', data)
--         return
--     end

--     local newData = json.decode(data)
--     local action = newData['action']
--     if action == 'updateRules' then
--         local newBlackIps = newData['black_ip']
--         if newBlackIps ~= nil then
--             _M.SaveOrUpdateBlackIps(newBlackIps, oldBlackIps)
--         end
--         local newSystemInfo = newData['system_info']
--         if newSystemInfo ~= nil then
--             dataNewSystem = _M.SaveOrUpdateSystemInfo(newSystemInfo, oldSystemInfo)
--         end
--     end
--     -- 将系统信息更新到data
--     dataTable['system_info'] = dataNewSystem
--     dataProcess.setRedis('data', json.encode(dataTable))
--     -- 记录更新日志
--     logRecord.log_record(logPath, ngx.var.request_uri, TableUtil.TableToStr(dataNewSystem), 'saveOrupdateSystemInfo')
--     ngx.log(ngx.DEBUG, '保存系统信息日志成功')
--     Log('dataNewSystem:' .. dataNewSystem)
--     return dataNewSystem
-- end

-- 新增或编辑策略
function _M.dealStrategy(newData)
    local ip = newData['ip']
    if ip == nil then
        return
    end
    local ipKey = prefix .. ip
    Log('ipKey:' .. ipKey)
    local oldStrategy = dataProcess.getRedisData(ipKey)
    -- 设置策略的过期时间
    local expireTime = newData['strategy_expire_time']
    if oldStrategy == ngx.null then
        Log('新增策略')
        newData['id'] = uuid()
        newData['id'] = tostring(newData['id']).gsub(newData['id'], '-', '')
        dataProcess.setRedis(ipKey, json.encode(newData))
        if expireTime ~= ngx.null then
            dataProcess.setRedisExpire(ipKey, expireTime)
        end
        return newData
    else
        Log('更新策略')
        local oldDataTable = json.decode(oldStrategy)
        oldDataTable = {
            ['id'] = oldDataTable['id'],
            ['ip'] = newData['ip'],
            ['state'] = newData['state'],
            ['action'] = newData['action'],
            ['redirect_server'] = newData['redirect_server'],
            ['redirect_host'] = newData['redirect_host'],
            ['is_delay'] = newData['is_delay'],
            ['delay_time'] = newData['delay_time'],
            ['port_rule'] = newData['port_rule'],
            ['uri_rule'] = newData['uri_rule'],
            ['header_rule'] = newData['header_rule'],
            ['system_id'] = newData['system_id'],
            ['strategy_expire_time'] = newData['strategy_expire_time'],
            ['bind_time'] = newData['bind_time'],
            ['time_out'] = newData['time_out'],
            ['connect_count'] = newData['connect_count'],
            ['crud'] = newData['crud']
        }
        dataProcess.setRedis(ipKey, json.encode(oldDataTable))
        if expireTime ~= ngx.null then
            dataProcess.setRedisExpire(ipKey, expireTime)
        end
        return oldDataTable
    end
end

-- 新增或编辑策略
function _M.dealHostStrategy(newData)
    local host = newData['host']
    if host == nil then
        return
    end
    local hostKey = prefix .. host
    Log('hostKey:' .. hostKey)
    local oldStrategy = dataProcess.getRedisData(hostKey)
    -- 设置策略的过期时间
    local expireTime = newData['strategy_expire_time']
    if oldStrategy == ngx.null then
        Log('新增策略')
        newData['id'] = uuid()
        newData['id'] = tostring(newData['id']).gsub(newData['id'], '-', '')
        dataProcess.setRedis(hostKey, json.encode(newData))
        if expireTime ~= ngx.null then
            dataProcess.setRedisExpire(hostKey, expireTime)
        end
        return newData
    else
        Log('更新策略')
        local oldDataTable = json.decode(oldStrategy)
        oldDataTable = {
            ['id'] = oldDataTable['id'],
            ['host'] = newData['host'],
            ['is_domain'] = newData['is_domain'],
            ['state'] = newData['state'],
            ['action'] = newData['action'],
            ['redirect_server'] = newData['redirect_server'],
            ['redirect_host'] = newData['redirect_host'],
            ['is_delay'] = newData['is_delay'],
            ['delay_time'] = newData['delay_time'],
            ['port_rule'] = newData['port_rule'],
            ['uri_rule'] = newData['uri_rule'],
            ['header_rule'] = newData['header_rule'],
            ['system_id'] = newData['system_id'],
            ['strategy_expire_time'] = newData['strategy_expire_time'],
            ['bind_time'] = newData['bind_time'],
            ['time_out'] = newData['time_out'],
            ['connect_count'] = newData['connect_count'],
            ['crud'] = newData['crud']
        }
        dataProcess.setRedis(hostKey, json.encode(oldDataTable))
        if expireTime ~= ngx.null then
            dataProcess.setRedisExpire(hostKey, expireTime)
        end
        return oldDataTable
    end
end

-- 删除策略
function _M.deleteStrategy(newData)
    local ips = StrUtil.Split(newData['ips'], ',')
    for i = 1, #ips do
        Log('ips:' .. ips[i])
        local ipkey = prefix .. ips[i]
        dataProcess.deleteRedisData(ipkey)
        Log('正在删除策略：' .. ipkey)
    end
end

-- 新增或编辑蜜罐配置
function _M.dealHoney(newData)
    local id = newData['id']
    if id == nil then
        Log('新增策略')
        local newId = uuid()
        newId = tostring(newId).gsub(newId, '-', '')
        newData['id'] = newId
        dataProcess.setRedis(honeyPrefix .. newId, json.encode(newData))
        return newData
    else
        local idKey = honeyPrefix .. id
        Log('idKey:' .. idKey)
        local oldHoney = dataProcess.getRedisData(idKey)
        Log('更新策略')
        local oldDataTable = json.decode(oldHoney)
        oldDataTable = {
            ['id'] = oldDataTable['id'],
            ['name'] = newData['name'],
            ['port'] = newData['port'],
            ['host'] = newData['host'],
            ['url'] = newData['url'],
            ['instruction'] = newData['instruction'],
            ['action'] = newData['action']
        }
        dataProcess.setRedis(idKey, json.encode(oldDataTable))
        return oldDataTable
    end
end

-- 删除蜜罐配置
function _M.deleteHoney(newData)
    -- local newData = json.decode(data)
    local ids = StrUtil.Split(newData['ids'], ',')
    for i = 1, #ids do
        Log('ids:' .. ids[i])
        local idKey = honeyPrefix .. ids[i]
        dataProcess.deleteRedisData(idKey)
        Log('正在删除蜜罐：' .. idKey)
    end
end

return _M
