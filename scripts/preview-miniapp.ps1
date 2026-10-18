# 启动「小程序浏览器预览」（Node 静态服务 + /api 反代到后端 8080，默认端口 8850）
#
# 用途：本机未安装微信开发者工具时，用浏览器按**真实 WXML / WXSS / JS** 查看两个小程序的页面效果：
#   * C 端小程序   poyang-crab-miniapp
#   * 渠道商端小程序 poyang-crab-channel
# 预览服务会用本地 JWT 密钥签发「预览令牌」注入登录态，因此报单、订单、会员等需登录页面也能看到真实数据。
#
# 用法：
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\preview-miniapp.ps1
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\preview-miniapp.ps1 -Port 8851 -NoOpen
[CmdletBinding()]
param(
    [int]$Port = 8850,
    [switch]$NoOpen
)

. "$PSScriptRoot\_common.ps1"

Write-Title "启动小程序浏览器预览（:$Port）"

Assert-Dir $MiniDir 'C 端小程序目录'
Assert-Dir $ChannelDir '渠道商端小程序目录'

$serverJs = Join-Path $PSScriptRoot 'miniapp-preview\server.mjs'
if (-not (Test-Path $serverJs)) {
    Write-Err "缺少预览服务脚本：$serverJs"
    exit 1
}

$node = Get-Command node.exe -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Err '未找到 node.exe，请先安装 Node.js 18+ 并加入 PATH'
    exit 1
}
Write-Step "Node：$($node.Source)"
Write-Step "预览源码：$serverJs"

# 后端是否在线（预览只是浏览器替身，数据仍来自后端）
if (Wait-HttpOk -Url "http://localhost:$BackendPort/api/actuator/health" -TimeoutSec 3) {
    Write-Ok "后端 :$BackendPort 正常"
} else {
    Write-Warn "后端 :$BackendPort 未就绪：预览可以打开，但接口会返回 502"
    Write-Step '请另开窗口执行：scripts\start-backend.bat'
}

$url = "http://localhost:$Port/preview/"

$ownerPid = Get-ListenPid $Port
if ($ownerPid -gt 0) {
    Write-Warn "端口 $Port 已被占用（PID $ownerPid）"
    if (Wait-HttpOk -Url $url -TimeoutSec 5) {
        Write-Ok "预览已在运行：$url"
        if (-not $NoOpen) { Start-Process $url }
        exit 0
    }
    Write-Err "该端口被其它程序占用，请换端口重试，例如：-Port 8851"
    exit 1
}

$command = "node $serverJs --port $Port"
$windowPid = Start-ServiceWindow -Title "小程序预览 :$Port" -WorkDir $CrabRoot -Command $command -LogName 'miniapp-preview'
Save-ServicePid -Name 'miniapp-preview' -ProcessId $windowPid
Write-Step "已在新窗口启动（窗口 PID $windowPid），日志：$LogDir\miniapp-preview.log"
Write-Step '等待就绪...'

if (Wait-HttpOk -Url $url -TimeoutSec 40) {
    Write-Ok "预览就绪：$url"
    Write-Step "C 端小程序   ：${url}#miniapp"
    Write-Step "渠道商端小程序：${url}#channel"
    Write-Step "单端独立窗口 ：http://localhost:$Port/preview/single.html?app=channel"
    if (-not $NoOpen) { Start-Process $url }
    exit 0
}

Write-Err "等待超时。请查看日志：$LogDir\miniapp-preview.log（错误输出：$LogDir\miniapp-preview.err.log）"
exit 1
