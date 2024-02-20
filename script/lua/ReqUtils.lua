local _M = {}

function _M.getReqIp()
    -- 获取请求ip
    local headers = ngx.req.get_headers()
    local ip = headers['x-forwarded-for']
    if ip == nil or string.len(ip) == 0 or ip == 'unknown' then
        ip = headers['Proxy-Client-IP']
    end
    if ip == nil or string.len(ip) == 0 or ip == 'unknown' then
        ip = headers['WL-Proxy-Client-IP']
    end
    if ip == nil or string.len(ip) == 0 or ip == 'unknown' then
        ip = ngx.var.remote_addr
    end
    -- 对于通过多个代理的情况，第一个IP为客户端真实IP,多个IP按照','分割
    if ip ~= nil and string.len(ip) > 15 then
        local pos = string.find(ip, ',', 1)
        ip = string.sub(ip, 1, pos - 1)
    end
    return ip
end

-- tcp获取ip
function _M.tcpGetIp()
    local ip = ngx.var.remote_addr
    ngx.log(ngx.DEBUG, ip)
    return ip
end

-- 获取user-agent
function _M.get_user_agent()
    local USER_AGENT = ngx.var.http_user_agent
    if USER_AGENT == nil then
        USER_AGENT = 'unknown'
    end
    return USER_AGENT
end

-- 获取host
function _M.get_server_host()
    local host = ngx.req.get_headers()['Host']
    return host
end

-- 获取domain host
function _M.get_host()
    return ngx.var.host
end

return _M

-- local h = ngx.req.get_headers()
-- for k,v in pairs(h) do
--     ngx.say(k .. : .. v)
-- end
-- local remote_addr = ngx.var.remote_addr
-- ngx.say(remote_addr)

-- local request_uri = ngx.var.request_uri
-- ngx.say(request_uri)
-- local server_name = ngx.var.server_name
-- ngx.say(server_name)
-- local server_port = ngx.var.server_port
-- ngx.say(server_port)
