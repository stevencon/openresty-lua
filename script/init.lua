MyShared = ngx.shared.MyShared
StrUtil = require 'stringHelper'
FileUtil = require 'FileHelper'
TableUtil = require 'TableHelper'
JwtUtil = require 'JwtUtil'

local logPath = 'script/config_json/log_path.json'
local redisConfig = 'script/config_json/redis_config.json'
local jwtConfig = 'script/config_json/jwt_config.json'

LogPathTable = FileUtil.Loadjson(logPath)
RedisConfigTable = FileUtil.Loadjson(redisConfig)
JwtConfigTable = FileUtil.Loadjson(jwtConfig)

function GetShared(key, default)
    local value, flag = MyShared:get(key)
    return value or default, flag
end

function GetSharedStale(key, default)
    local value, flag, isOverdue = MyShared:get_stale(key)
    return value or default, flag, isOverdue
end

function DelShared(key)
    if not GetShared(key, nil) then
        return false
    end
    MyShared:delete(key)
    return true
end

--[[flags：自定义值，读取时带回  exptime:过期时间，单位是秒]]
function SetShared(key, value, exptime, flags)
    local success, err, forcible = MyShared:set(key, value, exptime or 0, flags)
    return success, err, forcible
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

function Log(str)
    ngx.log(ngx.DEBUG, str)
end
