local chunk, eof = ngx.arg[1], ngx.arg[2]
if ngx.ctx.buffered == nil then
    ngx.ctx.buffered = {}
end
if chunk ~= '' and not ngx.is_subrequest then
    table.insert(ngx.ctx.buffered, chunk)
    ngx.arg[1] = nil
end

local oldContent = nil
if eof then
    --ngx.log(ngx.DEBUG, 2)
    oldContent = table.concat(ngx.ctx.buffered)
    ngx.ctx.buffered = nil
    -- 重新赋值响应数据，以修改后的内容作为最终响应
    local newContent = BodyHandle(oldContent)
    ngx.arg[1] = newContent
end

function BodyHandle(body)
    Log('body 执行11111111111111111111111')
    --whole = string.gsub(whole, 'href=\/', 'href=\')
    --whole = string.gsub(whole, 'src=\/', 'src=\')
    ngx.log(ngx.DEBUG, ngx.var.uri)
    body = string.gsub(body, '/>', ' />')
    body = string.gsub(body, '=/(%w)', '=%1')
    body = string.gsub(body, '//www.baidu.com/', '')

    body = string.gsub(body, '</title>', '</title><base href=/ />')
    body = string.gsub(body, 'http://www.baidu.com', '')
    return body
end
