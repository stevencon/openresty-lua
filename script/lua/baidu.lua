local _M = {}



function _M.HandleRewrite()
    Log(执行黑名单rewrite)
    local ipTable = ngx.ctx.ipTable
    if ipTable ~= nil then
        ngx.var.rewriteUrl = ipTable['rewriteUrl'] .. ngx.ctx.ipTable['routeUrl']
        ngx.var.routeHost = ngx.ctx.ipTable['routeUrl']
    end
end

return _M