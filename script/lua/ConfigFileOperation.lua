local addSystemInfo = require('AddSystemInfo')
local reboot = require('KillMyself')
local monitorPort = require('MonitorPort')
local fileBak = require('FileBak')
local fileCallBack = require('FileCallBack')
local checkNgx = require('CheckNgxStatus')
local systemInfo = require('UpdateSystem')

-- system数据
local data = systemInfo.getPostArgs()
Log('data:' .. type(data))

if data == nil then
    Log('data是空的，不进行数据更新')
    ngx.exit(510)
end

-- 监测端口是否正常
local res = monitorPort.monitorPort(data)
Log('res:' .. res)
if res ~= '0' then
    Log('端口已被占用')
    ngx.exit(500)
end

--备份文件
fileBak.fileCopy()

--写文件
addSystemInfo.sendRequestSetConfigFile(data)

-- 检测nginx是否正常
local checkRes = checkNgx.checkNgx()
if checkRes ~= '0' then
    Log('nginx文件不正常，请执行回滚操作')
    -- 调回滚，重启
    fileCallBack.fileCallBack()
end

--重启
reboot.reboot()
