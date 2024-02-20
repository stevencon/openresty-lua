--[[日志记录]]
local reqUtils = require('ReqUtils')
local json = require('cjson')

local _M = {}

function _M.file_exists(path)
    local file = io.open(path, 'rb')
    if file then
        file:close()
    end
    return file ~= nil
end

function _M.log_record(log_dir, url, data, ruleType)
    local log_path = log_dir
    -- 判断目录是否存在,不存在则新建文件夹
    Log('log_path:' .. log_path)
    if _M.file_exists(log_path) == false then
        os.execute('mkdir' .. ' ' .. LogPathTable['project_address'] .. log_path)
    -- os.execute('mkdir G:\\openResty\\openresty_drainage\\' .. string.gsub(log_path, './', ''))
    end
    local reqIp = reqUtils.getReqIp()
    local user_agent = reqUtils.get_user_agent()
    local server_name = ngx.var.server_name
    local local_time = ngx.localtime()
    local remote_port = ngx.var.remote_port
    local server_port = ngx.var.server_port
    local log_json_obj = {
        reqIp = reqIp,
        local_time = local_time,
        server_name = server_name,
        user_agent = user_agent,
        req_url = url,
        req_data = data,
        remote_port = remote_port,
        server_port = server_port
    }
    local log_line = json.encode(log_json_obj)
    local log_name = string.format('%s/%s_%s.log', log_path, ruleType, ngx.today())
    FileUtil.FileWrite(log_name, log_line)
    return true
end

return _M
