local waf = require('waf')

-- local serverPort = ngx.var.server_port
-- local remotePort = ngx.var.remote_port
-- Log('serverPort:' .. serverPort)
-- Log('remotePort:' .. remotePort)

waf.check()

