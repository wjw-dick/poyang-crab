# 启动后台管理前端：vue-pure-admin 风格（Vite dev server，端口 8848，/api 代理到 8080）
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File scripts\start-admin.ps1
[CmdletBinding()]
param(
    [int]$TimeoutSec = 180,
    [switch]$SkipInstall
)

. "$PSScriptRoot\_common.ps1"

Write-Title "启动后台管理前端（Vite / :$AdminPort）"
Assert-Dir $AdminDir '后台前端目录'

$homeUrl = "http://localhost:$AdminPort/"

$ownerPid = Get-ListenPid $AdminPort
if ($ownerPid -gt 0) {
    Write-Warn "端口 $AdminPort 已被占用（PID $ownerPid），跳过启动"
    if (Wait-HttpOk -Url $homeUrl -TimeoutSec 5) { Write-Ok "后台已在运行：$homeUrl" }
    exit 0
}

if (-not $SkipInstall) {
    Ensure-NodeModules -Dir $AdminDir -Name '后台前端'
}

$windowPid = Start-ServiceWindow -Title "后台 :$AdminPort" -WorkDir $AdminDir -Command 'npm.cmd run dev' -LogName 'admin'
Save-ServicePid -Name 'admin' -ProcessId $windowPid
Write-Step "已在新窗口启动（窗口 PID $windowPid），日志：$LogDir\admin.log"
Write-Step '等待就绪...'

if (Wait-HttpOk -Url $homeUrl -TimeoutSec $TimeoutSec) {
    Write-Ok "后台就绪：$homeUrl"
    exit 0
}

Write-Err "等待超时。请查看日志：$LogDir\admin.log（错误输出：$LogDir\admin.err.log）"
exit 1
