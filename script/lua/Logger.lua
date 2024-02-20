local _M = {}

function _M.log(log_dir, format, ...)
    if ngx.ctx.log_slot == nil then
        ngx.ctx.log_slot = {}
    end
    local arg = {...}
    local logstr = ''
    ngx.log(ngx.DEBUG,'arg:' .. TableUtil.TableToStr(arg))
    if arg == nil then
        logstr = format
    else
        logstr = string.format(format, table.unpack(arg))
    end
    logstr = logstr .. '\t' .. ngx.now()
    table.insert(ngx.ctx.log_slot, logstr)
    ngx.ctx.log_dir = log_dir
end

return _M
