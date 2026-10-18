# 启动 H5 / PC 官网前端（Vite dev server，端口 8849，/api 代理到 8080）
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File scripts\start-h5.ps1
[CmdletBinding()]
param(
    [int]$TimeoutSec = 180,
    [switch]$SkipInstall
)

. "$PSScriptRoot\_common.ps1"

Write-Title "启动 H5 / PC 官网前端（Vite / :$H5Port）"
Assert-Dir $H5Dir 'H5 目录'

$homeUrl = "http://localhost:$H5Port/"

$ownerPid = Get-ListenPid $H5Port
if ($ownerPid -gt 0) {
    Write-Warn "端口 $H5Port 已被占用（PID $ownerPid），跳过启动"
    if (Wait-HttpOk -Url $homeUrl -TimeoutSec 5) { Write-Ok "H5 已在运行：$homeUrl" }
    exit 0
}

if (-not $SkipInstall) {
    Ensure-NodeModules -Dir $H5Dir -Name 'H5 前端'
}

$windowPid = Start-ServiceWindow -Title "H5 :$H5Port" -WorkDir $H5Dir -Command 'npm.cmd run dev' -LogName 'h5'
Save-ServicePid -Name 'h5' -ProcessId $windowPid
Write-Step "已在新窗口启动（窗口 PID $windowPid），日志：$LogDir\h5.log"
Write-Step '等待就绪...'

if (Wait-HttpOk -Url $homeUrl -TimeoutSec $TimeoutSec) {
    Write-Ok "H5 就绪：$homeUrl"
    exit 0
}

Write-Err "等待超时。请查看日志：$LogDir\h5.log（错误输出：$LogDir\h5.err.log）"
exit 1
