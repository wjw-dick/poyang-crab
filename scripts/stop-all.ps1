# 停止全部服务：后端 8080 / 后台 8848 / H5 8849
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File scripts\stop-all.ps1
. "$PSScriptRoot\_common.ps1"

Write-Title '停止全部服务'

$services = @(
    @{ Name = 'backend';         Label = '后端';       Port = $BackendPort },
    @{ Name = 'admin';           Label = '后台前端';   Port = $AdminPort   },
    @{ Name = 'h5';              Label = 'H5 前端';    Port = $H5Port      },
    @{ Name = 'miniapp-preview'; Label = '小程序预览'; Port = $PreviewPort }
)

foreach ($svc in $services) {
    $done = Stop-ByPidFile -Name $svc.Name -Label $svc.Label
    if (-not $done) {
        $done = Stop-ByPort -Port $svc.Port -Label $svc.Label
    }
    if (-not $done) { Write-Step "$($svc.Label) 未在运行（端口 $($svc.Port) 空闲）" }
}

Write-Title '完成'
foreach ($svc in $services) {
    $ownerPid = Get-ListenPid $svc.Port
    if ($ownerPid -gt 0) { Write-Warn "$($svc.Label) 端口 $($svc.Port) 仍被 PID $ownerPid 占用" }
}
Write-Host '  已释放端口：8080 / 8848 / 8849 / 8850' -ForegroundColor DarkGray
