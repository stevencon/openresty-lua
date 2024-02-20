local _M = {}
local json = require('cjson')
local jwt = require('resty.jwt')
local secret = 'jwt-certificate'

-- 认证
function _M.auth(isFind)
    local auth_header = ngx.var.http_Authorization

    if auth_header == nil then
        ngx.log(ngx.DEBUG, 'No Authorization header')
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    ngx.log(ngx.DEBUG, 'Authorization: ' .. auth_header)

    local _, _, token = string.find(auth_header, 'Bearer%s+(.+)')

    if token == nil then
        ngx.log(ngx.DEBUG, 'Missing token')
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    ngx.log(ngx.DEBUG, 'Token: ' .. token)

    local jwt_obj = jwt:verify(secret, token)
    if jwt_obj.verified == false then
        ngx.log(ngx.DEBUG, 'Invalid token: ' .. jwt_obj.reason)

        ngx.status = ngx.HTTP_UNAUTHORIZED
        ngx.header.content_type = 'application/json; charset=utf-8'
        ngx.say(json.encode(jwt_obj))
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    --由于jwt的负载已经加了过期时间，这里就不用手动判断一次了
    -- local past_time = jwt_obj['payload']['exp']
    -- if payload ~= nil then
    --     local time_diff = tonumber(past_time) - tonumber(ngx.time())
    --     if time_diff < 0 then
    --         ngx.log(ngx.DEBUG, 'The token is invalid.Please regenerate the certificate!')
    --         ngx.exit(ngx.HTTP_UNAUTHORIZED)
    --     end
    -- end
    ngx.log(ngx.DEBUG, 'JWT: ' .. json.encode(jwt_obj))
    if not isFind then
        ngx.say(json.encode(jwt_obj))
    end
    -- ngx.say(json.encode(jwt_obj))
end

--签名
function _M.sign(expire_time)
    local timestamp = ngx.time()
    local jwt_token = nil
    ngx.log(ngx.DEBUG, 'expire_time:' .. expire_time)
    -- expire_time为0，则无过期时间，不为0，则设置过期时间
    if expire_time ~= 0 then
        ngx.log(ngx.DEBUG, '设置过期时间')
        jwt_token =
            jwt:sign(
            secret,
            {
                header = {typ = 'JWT', alg = 'HS256'},
                payload = {
                    foo = 'bar',
                    ss = 'lxy',
                    ip = ngx.var.remote_addr,
                    iat = timestamp,
                    exp = tonumber(timestamp) + expire_time
                }
            }
        )
    else
        ngx.log(ngx.DEBUG, '不设置过期时间')
        jwt_token =
            jwt:sign(
            secret,
            {
                header = {typ = 'JWT', alg = 'HS256'},
                payload = {
                    foo = 'bar',
                    ss = 'lxy',
                    ip = ngx.var.remote_addr,
                    iat = timestamp
                }
            }
        )
    end
    Log('sign success!')
    Log('token:' .. 'Bearer ' .. jwt_token)
    ngx.say('jwt_token:' .. 'Bearer ' .. jwt_token)
end

return _M
