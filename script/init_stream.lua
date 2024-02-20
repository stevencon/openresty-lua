StreamShared = ngx.shared.StreamShared
StrUtil = require 'stringHelper'
FileUtil = require 'FileHelper'
TableUtil = require 'TableHelper'

local logPath = 'script/config_json/log_path.json'
local redisConfig = 'script/config_json/redis_config.json'

LogPathTable = FileUtil.Loadjson(logPath)
RedisConfigTable = FileUtil.Loadjson(redisConfig)

function GetShared(key, default)
    local value, flag = StreamShared:get(key)
    return value or default, flag
end

function GetSharedStale(key, default)
    local value, flag, isOverdue = StreamShared:get_stale(key)
    return value or default, flag, isOverdue
end

function DelShared(key)
    if not GetShared(key, nil) then
        return false
    end
    StreamShared:delete(key)
    return true
end

--[[flags：自定义值，读取时带回  exptime:过期时间，单位是秒]]
function SetShared(key, value, exptime, flags)
    local success, err, forcible = StreamShared:set(key, value, exptime or 0, flags)
    return success, err, forcible
end

function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

function RequireEx(_mname, currentVersion)
    ngx.log(ngx.DEBUG, string.format('require_ex = %s', _mname))
    if package.loaded[_mname] then
        if package.loaded[_mname].GetVersion() ~= currentVersion then
            package.loaded[_mname] = nil
        end
        ngx.log(ngx.DEBUG, string.format('require_ex module[%s] reload', _mname))
    end
    return require(_mname)
end

function LogStr(str)
    ngx.log(ngx.DEBUG, str)
end
