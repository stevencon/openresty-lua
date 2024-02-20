local logRecord = require('LogRecord')

local request_time = ngx.var.request_time
Log('requestTime:' .. request_time)
-- 不记录小于一秒的请求
-- if tonumber(request_time) < 0.01 then
--     return
-- end

local slot = ngx.ctx.log_slot
if slot == nil or type(slot) ~= 'table' then
    return
end
local logs = table.concat(slot, '\n')
logRecord.log_record(ngx.ctx.log_dir, ngx.var.request_uri, logs, '')
