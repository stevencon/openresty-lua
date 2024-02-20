local _M = {}
local http = require('resty.http')
local httpc = http.new()
local json = require('cjson')
-- local goIp = '192.168.20.166'
local goIp = GetShared('go_ip')

function _M.sendRequestSetConfigFile(data)
    local res, err =
        httpc:request_uri(
        'http://' .. goIp .. ':8090/api/file/api/v1/systemInfo',
        {
            method = 'POST',
            -- body = data,
            body = json.encode(data),
            headers = {
                ['Content-Type'] = 'application/x-www-form-urlencoded'
            },
            keepalive_timeout = 60,
            keepalive_pool = 10
        }
    )

    -- if not res or res.status then
    --     ngx.log(ngx.DEBUG, 'request error#', err)
    --     return
    -- end

    -- ngx.log(ngx.ERR, 'request status#', res.status)
    -- ngx.say(res.body)
end

function _M.KillMyself()
    local res, err =
        httpc:request_uri(
        'http://' .. goIp .. ':8090/api/ngx/api/v1/reboot',
        {
            method = 'POST',
            headers = {
                ['Content-Type'] = 'application/x-www-form-urlencoded'
            },
            keepalive_timeout = 60,
            keepalive_pool = 10
        }
    )

    -- if not res or res.status then
    --     ngx.log(ngx.DEBUG, 'request error#', err)
    --     return
    -- end

    -- ngx.log(ngx.ERR, 'request status#', res.status)
    -- ngx.say(res.body)
end

function _M.MonitorPort(data)
    local res, err =
        httpc:request_uri(
        'http://' .. goIp .. ':8090/api/ngx/api/v1/detectionListenerPort',
        {
            method = 'POST',
            body = json.encode(data),
            headers = {
                ['Content-Type'] = 'application/x-www-form-urlencoded'
            },
            keepalive_timeout = 60,
            keepalive_pool = 10
        }
    )

    -- if not res or res.status then
    --     ngx.log(ngx.DEBUG, 'request error#', err)
    --     return
    -- end

    -- ngx.log(ngx.ERR, 'request status#', res.status)
    -- ngx.say(res.body)
    return tostring(res.body)
end

function _M.FileCopy()
    local res, err =
        httpc:request_uri(
        'http://' .. goIp .. ':8090/api/file/api/v1/fileCopy',
        {
            method = 'POST',
            headers = {
                ['Content-Type'] = 'application/x-www-form-urlencoded'
            },
            keepalive_timeout = 60,
            keepalive_pool = 10
        }
    )

    -- if not res or res.status then
    --     ngx.log(ngx.DEBUG, 'request error#', err)
    --     return
    -- end

    -- ngx.log(ngx.ERR, 'request status#', res.status)
    -- ngx.say(res.body)
end

function _M.checkNgx()
    local res, err =
        httpc:request_uri(
        'http://' .. goIp .. ':8090/api/ngx/api/v1/checkNgx',
        {
            method = 'POST',
            headers = {
                ['Content-Type'] = 'application/x-www-form-urlencoded'
            },
            keepalive_timeout = 60,
            keepalive_pool = 10
        }
    )

    -- if not res or res.status then
    --     ngx.log(ngx.DEBUG, 'request error#', err)
    --     return
    -- end

    -- ngx.log(ngx.ERR, 'request status#', res.status)
    -- ngx.say(res.body)
    return tostring(res.body)
end

function _M.fileCallBack()
    local res, err =
        httpc:request_uri(
        'http://' .. goIp .. ':8090/api/file/api/v1/fileCallBack',
        {
            method = 'POST',
            headers = {
                ['Content-Type'] = 'application/x-www-form-urlencoded'
            },
            keepalive_timeout = 60,
            keepalive_pool = 10
        }
    )

    -- if not res or res.status then
    --     ngx.log(ngx.DEBUG, 'request error#', err)
    --     return
    -- end

    -- ngx.log(ngx.ERR, 'request status#', res.status)
    -- ngx.say(res.body)
    return tostring(res.body)
end

return _M
