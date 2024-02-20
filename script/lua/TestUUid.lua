local uuid = require('resty.jit-uuid')
-- uuid.seed()

ngx.log(ngx.DEBUG, 'uuid1:' .. uuid())
ngx.log(ngx.DEBUG, 'uuid2:' .. uuid())
ngx.log(ngx.DEBUG, 'uuid3:' .. uuid())

local arg = {'sourceIp:10.10.1.172'}
logstr = string.format('sourceIp:10.10.1.172', table.unpack(arg))
ngx.log(ngx.DEBUG, 'logstr:' .. logstr)
