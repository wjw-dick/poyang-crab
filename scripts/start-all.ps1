# 一键启动（原生 / 非 Docker）：依赖检查 → 数据库 → 后端 → 对象存储 → 后台 → H5
#
# 用法：
#   scripts\start-all.bat                              # 双击或命令行直接跑
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\start-all.ps1
#   ... -InitDb                                        # 顺带初始化数据库
#   ... -OnlyBackend                                   # 只启动后端
#   ... -SkipDeps                                      # 跳过依赖端口检查
[CmdletBinding()]
param(
    [switch]$InitDb,
    [switch]$SkipDeps,
    [switch]$OnlyBackend,
    [string]$AdminUser = 'admin',
    [string]$AdminPassword = 'Admin@123456'
)

. "$PSScriptRoot\_common.ps1"

function Switch-StorageToLocal {
    <#
      通过后端接口把对象存储驱动切换为 LOCAL：
      与后台页面走同一条链路（测试连接 → 保存并应用），
      同时正确写入数据库 is_active 与 Redis storage:active:driver。
    #>
    $base = "http://localhost:$BackendPort/api"
    $json = @{ username = $AdminUser; password = $AdminPassword } | ConvertTo-Json -Compress
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    try {
        # 注意：PowerShell 的 splatting 只支持变量（@params），内联 @{...} 会被当作位置参数，勿改回
        $login = Invoke-RestMethod -Uri "$base/auth/login" -Method Post -ContentType 'application/json' -Body $bodyBytes -TimeoutSec 15
        if (-not $login -or $login.code -ne 200) {
            $script:StorageSwitchError = "登录失败（code=$($login.code)）"
            return $false
        }

        $headers = @{ Authorization = "Bearer $($login.data.token)" }
        $null  = Invoke-RestMethod -Uri "$base/system/storage/test?driver=LOCAL"  -Method Post -Headers $headers -ContentType 'application/json' -Body '{}' -TimeoutSec 20
        $apply = Invoke-RestMethod -Uri "$base/system/storage/apply?driver=LOCAL" -Method Post -Headers $headers -ContentType 'application/json' -Body '{}' -TimeoutSec 20
        if ($apply.code -ne 200) {
            $script:StorageSwitchError = "应用失败（code=$($apply.code) $($apply.msg)）"
            return $false
        }
        return $true
    } catch {
        $script:StorageSwitchError = $_.Exception.Message
        return $false
    }
}

Write-Title '螃蟹小公主 · 鄱阳湖湖蟹 —— 一键启动（原生 / 非 Docker）'

# ---------------- 1. 依赖检查 ----------------
if (-not $SkipDeps) {
    Write-Title '1. 依赖检查'
    $targets = @(
        @{ Name = 'MySQL 8';  Host = $DbHost;     Port = $DbPort;     Fatal = $true  },
        @{ Name = 'Redis';    Host = $RedisHost;  Port = $RedisPort;  Fatal = $false },
        @{ Name = 'RabbitMQ'; Host = $RabbitHost; Port = $RabbitPort; Fatal = $false }
    )
    $missing = @()
    foreach ($t in $targets) {
        if (Test-TcpPort -ComputerName $t.Host -Port $t.Port) {
            Write-Ok ("{0,-9} {1}:{2} 可连接" -f $t.Name, $t.Host, $t.Port)
        } else {
            Write-Err ("{0,-9} {1}:{2} 未监听" -f $t.Name, $t.Host, $t.Port)
            $missing += $t.Name
            if ($t.Fatal) {
                Write-Host ''
                Write-Err 'MySQL 未运行，后端无法启动。请先启动本机 MySQL 服务后重试。'
                exit 1
            }
        }
    }
    if ($missing.Count -gt 0) {
        Write-Warn "以下组件未运行：$($missing -join '、')，后端可能启动失败或部分功能不可用"
    }
} else {
    Write-Step '已跳过依赖端口检查（-SkipDeps）'
}

# ---------------- 2. 数据库初始化（可选） ----------------
if ($InitDb) {
    Write-Title '2. 数据库初始化'
    & (Join-Path $PSScriptRoot 'init-db.ps1')
    if ($LASTEXITCODE -ne 0) { Write-Err '数据库初始化失败，已中止'; exit 1 }
} else {
    Write-Title '2. 数据库'
    Write-Step '跳过初始化（首次建库建表请加 -InitDb 或执行 scripts\init-db.bat）'
}

# ---------------- 3. 后端 ----------------
Write-Title '3. 启动后端'
& (Join-Path $PSScriptRoot 'start-backend.ps1')
if ($LASTEXITCODE -ne 0) { Write-Err '后端启动失败，已中止'; exit 1 }

# ---------------- 4. 对象存储驱动 ----------------
Write-Title '4. 对象存储驱动'
if (Test-TcpPort -Port $MinioPort) {
    Write-Ok "检测到 MinIO（:$MinioPort）在运行，沿用当前驱动配置"
} else {
    $current = ''
    $redisCli = Resolve-RedisCliExe
    if ($redisCli) {
        $raw = Invoke-NativeExe -FilePath $redisCli -Arguments @(
            '-h', $RedisHost, '-p', "$RedisPort", '--raw', 'get', 'storage:active:driver')
        # 后端使用 JSON 序列化，原始值为 "LOCAL"（带引号），这里去掉引号再比较
        $current = ($raw.Output | Out-String).Trim().Trim('"')
    }
    if ($current -eq 'LOCAL') {
        Write-Ok '当前驱动：LOCAL（本地磁盘 ./data/upload）'
    } else {
        $shown = if ($current) { $current } else { '未设置' }
        Write-Step "本机未部署 MinIO，尝试把驱动切换为 LOCAL（当前：$shown）..."
        $script:StorageSwitchError = ''
        if (Switch-StorageToLocal) {
            Write-Ok '已切换为 LOCAL（本地磁盘 ./data/upload）'
        } else {
            Write-Warn '自动切换未成功，请在后台「系统管理 → 对象存储」中测试并应用 LOCAL 驱动'
            if ($script:StorageSwitchError) { Write-Host "        原因：$script:StorageSwitchError" -ForegroundColor DarkGray }
        }
    }
}

# ---------------- 5. 前端 ----------------
if (-not $OnlyBackend) {
    Write-Title '5. 启动后台管理前端'
    & (Join-Path $PSScriptRoot 'start-admin.ps1')

    Write-Title '6. 启动 H5 / PC 官网'
    & (Join-Path $PSScriptRoot 'start-h5.ps1')
}

# ---------------- 汇总 ----------------
Write-Title '启动完成'
Write-Host ("  后端 API   : http://localhost:{0}/api" -f $BackendPort) -ForegroundColor White
Write-Host ("  健康检查   : http://localhost:{0}/api/actuator/health" -f $BackendPort) -ForegroundColor DarkGray
if (-not $OnlyBackend) {
    Write-Host ("  后台管理   : http://localhost:{0}/    账号 {1} / {2}" -f $AdminPort, $AdminUser, $AdminPassword) -ForegroundColor White
    Write-Host ("  H5 / 官网  : http://localhost:{0}/" -f $H5Port) -ForegroundColor White
}
Write-Host '  小程序     : 微信开发者工具导入 poyang-crab-miniapp（C端）/ poyang-crab-channel（渠道端）' -ForegroundColor DarkGray
Write-Host ''
Write-Host '  停止服务   : scripts\stop-all.bat   （或直接关闭上面对应的服务窗口）' -ForegroundColor Yellow
Write-Host ''
