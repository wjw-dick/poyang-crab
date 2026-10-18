# 启动后端：Spring Boot（dev profile，端口 8080，context-path /api）
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File scripts\start-backend.ps1
[CmdletBinding()]
param(
    [int]$TimeoutSec = 300
)

. "$PSScriptRoot\_common.ps1"

Write-Title "启动后端（Spring Boot / dev / :$BackendPort）"
Assert-Dir $BackendDir '后端目录'

$healthUrl = "http://localhost:$BackendPort/api/actuator/health"

$ownerPid = Get-ListenPid $BackendPort
if ($ownerPid -gt 0) {
    Write-Warn "端口 $BackendPort 已被占用（PID $ownerPid）"
    if (Wait-HttpOk -Url $healthUrl -TimeoutSec 5) {
        Write-Ok '后端已在运行，健康检查通过，跳过启动'
        exit 0
    }
    Write-Err '端口被占用但健康检查未通过，请先执行 scripts\stop-all.ps1 再重试'
    exit 1
}

$command = 'mvn.cmd -B -DskipTests spring-boot:run'
$windowPid = Start-ServiceWindow -Title "后端 :$BackendPort" -WorkDir $BackendDir -Command $command -LogName 'backend'
Save-ServicePid -Name 'backend' -ProcessId $windowPid
Write-Step "已在新窗口启动（窗口 PID $windowPid），日志：$LogDir\backend.log"
Write-Step "等待健康检查（最长 $TimeoutSec 秒）..."

if (Wait-HttpOk -Url $healthUrl -TimeoutSec $TimeoutSec) {
    Write-Ok "后端就绪：http://localhost:$BackendPort/api"
    Write-Step "健康检查：$healthUrl"
    exit 0
}

Write-Err "等待超时。请查看日志：$LogDir\backend.log（错误输出：$LogDir\backend.err.log）"
exit 1
