local json = require('cjson')
local request_method = ngx.var.request_method
local arg = nil
local redis = require 'resty.redis'
local logger = require('Logger')

local keys = 'strategy*'

local redishelper = require('redisHelper')

-- logger.log('记录的是%s==%s','vv','cc')

local host = ngx.var.route_host
ngx.log(ngx.DEBUG,'host:' .. host)

-- redishelper.Init()

-- local keyss = redishelper.GetKeys(keys)
-- local values = {}

-- for i = 1, #keyss do
--     local res = redishelper.get(keyss[i])
--     values[i] = res
-- end

-- for k, v in pairs(values) do
--     ngx.log(ngx.DEBUG, 'v:' .. v)
-- end

-- local str = 'strategy_127.0.0.1'
-- local array = StrUtil.Split(str, '_')
-- ngx.log(ngx.DEBUG, array[1])
-- ngx.log(ngx.DEBUG, array[2])



-- local result = StrUtil.StrSplit(str, 'strategy_')
-- ngx.log(ngx.DEBUG, 'result:' .. result)

-- redishelper.Init()
-- ngx.log(ngx.DEBUG, '连接结束')

-- local res = redishelper.get('admin-id')
-- ngx.say(res)

-- ngx.say(tostring(GetShared('v')))

-- redishelper.Init()
-- local jsons={
--     [ip]=127.0.0.1,
--     [lj_ttl]=3000,
--     [mg_url]=http://www.baidu.com,
--     [route_url]=www.baidu.com
-- }
-- local jsons1={
--     [ip]=23,
--     [lj_ttl]=3000,
--     [mg_url]=https://github.com,
--     [route_url]=github.com
-- }
-- local ip_j = {jsons,jsons1}
-- ngx.log(ngx.DEBUG,json.encode(ip_j))
-- redishelper.Set('ip_pool',json.encode(ip_j))

-- redishelper.close()

-- arg = json.encode(ip_j)
-- local resp = redishelper.Set('ip_pool',{'192.168.20.166','127.0.0.1'})
-- local resp = redishelper.Set('ip_pool',arg)
-- ngx.log(ngx.DEBUG,'set ip_pool success' .. tostring(resp))

-- ngx.log(ngx.DEBUG,json)
-- ngx.say(request_method)
-- if request_method == 'POST' then
--     ngx.say('进来了')
--     ngx.req.read_body()
--     arg = ngx.req.get_body_data()
-- end

-- -- ngx.say('获取到的arg是：',arg)
-- -- ngx.log(ngx.DEBUG,Json)
-- -- local cjson = require('cjson')
-- -- local json_tmp = cjson.decode(arg)
-- local json_tmp = json.decode(arg)

-- if json_tmp == nil then
--     ngx.say('是空')
-- end
-- -- local j1 = json_tmp['scripts'][1]['name']
-- local jt = json_tmp['scripts'][1]

-- ngx.say(type(jt))

-- for k, v in pairs(jt) do
--     ngx.say(v)
--     local success, err, forcible = SetShared(k, v, 0, 0)
--     ngx.say(success)
-- end

-- -- ngx.say('获取到的json是：'..j1)
-- --Util.FileWrite('./script/lua/j1.lua', j1)
