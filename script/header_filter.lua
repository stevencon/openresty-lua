ngx.header.content_length = nil
--ngx.header['X-systemId'] = ngx.var.systemId
--ngx.header['Set-Cookie']= 'ncSession='..ngx.var.userId..'|'..ngx.var.systemId..'; Path=/; Expires='
local location = ngx.header.location or ''
if StrUtil.IsStrInclude(location, 'https://', 'http://') then
    local start = string.find(location, '://') + 3
    start = string.find(location, '/', start)
    location = string.sub(location, start, string.len(location))
end
if string.sub(location, 1, 1) == '/' then
    location = string.sub(location, 2, string.len(location))
    location = 'http://127.0.0.1:11223/center/' .. ngx.var.userId .. '/' .. ngx.var.systemId .. '/' .. location
end
ngx.header.location = location
