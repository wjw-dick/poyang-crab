<#
  螃蟹小公主 · 鄱阳湖湖蟹 —— 原生开发脚本公共库
  适用：Windows PowerShell 5.1+ / PowerShell 7+（不依赖 Docker）
  用法：其他脚本首行写  . "$PSScriptRoot\_common.ps1"
  覆盖默认配置：设置同名环境变量即可，例如 CRAB_DB_PASSWORD / CRAB_DB_PORT
#>

$ErrorActionPreference = 'Stop'

# 统一控制台为 UTF-8，避免中文乱码（conhost 默认代码页常为 936）
try { & chcp.com 65001 > $null 2>&1 } catch { }
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

# ======================== 目录 ========================
$CrabRoot   = Split-Path -Parent $PSScriptRoot
$BackendDir = Join-Path $CrabRoot 'poyang-crab-backend'
$AdminDir   = Join-Path $CrabRoot 'poyang-crab-admin'
$H5Dir      = Join-Path $CrabRoot 'poyang-crab-h5'
$MiniDir    = Join-Path $CrabRoot 'poyang-crab-miniapp'
$ChannelDir = Join-Path $CrabRoot 'poyang-crab-channel'
$SqlDir     = Join-Path $CrabRoot 'sql'
$RunDir     = Join-Path $CrabRoot '.run'
$LogDir     = Join-Path $CrabRoot 'logs'

# ======================== 应用端口 ========================
$BackendPort = 8080
$AdminPort   = 8848
$H5Port      = 8849
$PreviewPort = 8850   # 小程序浏览器预览（scripts\preview-miniapp.ps1，非业务服务，可随时关）
$MinioPort   = 9000

# ======================== 中间件（环境变量可覆盖） ========================
$DbHost     = if ($env:CRAB_DB_HOST)     { $env:CRAB_DB_HOST }     else { '127.0.0.1' }
$DbPort     = if ($env:CRAB_DB_PORT)     { [int]$env:CRAB_DB_PORT } else { 3306 }
$DbName     = if ($env:CRAB_DB_NAME)     { $env:CRAB_DB_NAME }     else { 'poyang_crab' }
$DbUser     = if ($env:CRAB_DB_USER)     { $env:CRAB_DB_USER }     else { 'poyang_crab' }
$DbPassword = if ($env:CRAB_DB_PASSWORD) { $env:CRAB_DB_PASSWORD } else { 'BZcEXmWxiDcmx5bw' }
$RedisHost  = if ($env:CRAB_REDIS_HOST)  { $env:CRAB_REDIS_HOST }  else { '127.0.0.1' }
$RedisPort  = if ($env:CRAB_REDIS_PORT)  { [int]$env:CRAB_REDIS_PORT } else { 6379 }
$RabbitHost = if ($env:CRAB_RABBIT_HOST) { $env:CRAB_RABBIT_HOST } else { '127.0.0.1' }
$RabbitPort = if ($env:CRAB_RABBIT_PORT) { [int]$env:CRAB_RABBIT_PORT } else { 5672 }

# ======================== 输出辅助 ========================
function Write-Title { param([string]$Text) Write-Host ''; Write-Host "===== $Text =====" -ForegroundColor Cyan }
function Write-Step  { param([string]$Text) Write-Host "  [*]  $Text" -ForegroundColor Gray }
function Write-Ok    { param([string]$Text) Write-Host "  [OK] $Text" -ForegroundColor Green }
function Write-Warn  { param([string]$Text) Write-Host "  [!]  $Text" -ForegroundColor Yellow }
function Write-Err   { param([string]$Text) Write-Host "  [X]  $Text" -ForegroundColor Red }

# ======================== 探测工具 ========================
function Test-TcpPort {
    param([string]$ComputerName = '127.0.0.1', [int]$Port, [int]$TimeoutMs = 800)
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect($ComputerName, $Port, $null, $null)
        if ($async.AsyncWaitHandle.WaitOne($TimeoutMs)) {
            $client.EndConnect($async)
            return $true
        }
        return $false
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

function Get-ListenPid {
    param([int]$Port)
    $conn = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($conn) { return [int]$conn.OwningProcess }
    return 0
}

function Wait-HttpOk {
    param([string]$Url, [int]$TimeoutSec = 120, [int]$IntervalMs = 1500)
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        try {
            $resp = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing
            if ($resp.StatusCode -eq 200) { return $true }
        } catch { }
        Start-Sleep -Milliseconds $IntervalMs
    }
    return $false
}

function Resolve-MysqlExe {
    $cmd = Get-Command mysql.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $candidates = @(
        'D:\BtSoft\mysql\MySQL8.0\bin\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe'
    )
    foreach ($root in @('D:\BtSoft\mysql', 'C:\Program Files\MySQL', 'C:\mysql', 'D:\mysql')) {
        if (Test-Path $root) {
            $found = Get-ChildItem -Path $root -Filter 'mysql.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { $candidates += $found.FullName }
        }
    }
    foreach ($p in $candidates) { if ($p -and (Test-Path $p)) { return $p } }
    return $null
}

function Resolve-RedisCliExe {
    $cmd = Get-Command redis-cli.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $candidates = @(
        'D:\BtSoft\redis\redis-cli.exe',
        'C:\Program Files\Redis\redis-cli.exe'
    )
    foreach ($root in @('D:\BtSoft\redis', 'C:\Redis', 'D:\Redis', 'C:\Program Files\Redis')) {
        if (Test-Path $root) {
            $found = Get-ChildItem -Path $root -Filter 'redis-cli.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { $candidates += $found.FullName }
        }
    }
    foreach ($p in $candidates) { if ($p -and (Test-Path $p)) { return $p } }
    return $null
}

# ======================== 进程启动 / 记录 ========================
function Start-ServiceWindow {
    <#
      在独立 PowerShell 窗口中启动服务，返回该窗口进程 PID（关掉窗口即停止该服务）。

      为什么要「重定向到文件 + 窗口 tail」而不是直接让服务写窗口：
        当窗口所在控制台无人消费输出（后台/隐藏窗口、缓冲写满）时，进程写 stdout 会**永久阻塞**，
        并持有 java.io.PrintStream 锁；若此时正在写 MyBatis SQL 日志，整个 Tomcat 线程池都会被拖死。
        因此服务进程的 stdout/stderr 一律落盘，窗口只做 tail —— 即使 tail 卡住，服务也照常运行。
    #>
    param(
        [string]$Title,
        [string]$WorkDir,
        [string]$Command,
        [string]$LogName
    )
    if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    $logFile = Join-Path $LogDir "$LogName.log"
    $errFile = Join-Path $LogDir "$LogName.err.log"

    $inner = @"
`$Host.UI.RawUI.WindowTitle = '$Title'
Set-Location -LiteralPath '$WorkDir'
Remove-Item -LiteralPath '$logFile','$errFile' -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path '$logFile','$errFile' -Force | Out-Null
Write-Host '[$Title] 实时日志（同时落盘：$logFile）' -ForegroundColor DarkGray
Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', '$Command' -WorkingDirectory '$WorkDir' -NoNewWindow -RedirectStandardOutput '$logFile' -RedirectStandardError '$errFile' | Out-Null
Get-Content -LiteralPath '$logFile' -Wait -Tail 80
"@
    $argStr = "-NoExit -NoProfile -ExecutionPolicy Bypass -Command `"$inner`""
    $proc = Start-Process -FilePath 'powershell.exe' -ArgumentList $argStr -PassThru
    return $proc.Id
}

function Save-ServicePid {
    param([string]$Name, [int]$ProcessId)
    if (-not (Test-Path $RunDir)) { New-Item -ItemType Directory -Path $RunDir -Force | Out-Null }
    Set-Content -Path (Join-Path $RunDir "$Name.pid") -Value $ProcessId -Encoding ASCII
}

function Read-ServicePid {
    param([string]$Name)
    $file = Join-Path $RunDir "$Name.pid"
    if (-not (Test-Path $file)) { return 0 }
    $raw = (Get-Content $file -Raw -ErrorAction SilentlyContinue)
    if ([string]::IsNullOrWhiteSpace($raw)) { return 0 }
    $value = 0
    if ([int]::TryParse($raw.Trim(), [ref]$value)) { return $value }
    return 0
}

function Stop-ByPidFile {
    param([string]$Name, [string]$Label)
    $targetPid = Read-ServicePid $Name
    if ($targetPid -le 0) { return $false }
    $alive = Get-Process -Id $targetPid -ErrorAction SilentlyContinue
    if (-not $alive) {
        Remove-Item (Join-Path $RunDir "$Name.pid") -Force -ErrorAction SilentlyContinue
        return $false
    }
    & taskkill.exe /PID $targetPid /T /F > $null 2>&1
    Remove-Item (Join-Path $RunDir "$Name.pid") -Force -ErrorAction SilentlyContinue
    Write-Ok "$Label 已停止（窗口 PID $targetPid）"
    return $true
}

function Stop-ByPort {
    param([int]$Port, [string]$Label)
    $targetPid = Get-ListenPid $Port
    if ($targetPid -le 0) { return $false }
    & taskkill.exe /PID $targetPid /T /F > $null 2>&1
    Write-Ok "$Label 已停止（端口 $Port / PID $targetPid）"
    return $true
}

function Ensure-NodeModules {
    param([string]$Dir, [string]$Name)
    if (Test-Path (Join-Path $Dir 'node_modules')) { return }
    Write-Warn "$Name 尚未安装依赖，开始执行 npm install（首次较慢，请耐心等待）..."
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    Push-Location $Dir
    try {
        & npm.cmd install
    } finally {
        Pop-Location
        $ErrorActionPreference = $saved
    }
    Write-Ok "$Name 依赖安装完成"
}

function Assert-Dir {
    param([string]$Path, [string]$Name)
    if (-not (Test-Path $Path)) {
        Write-Err "找不到 $Name：$Path"
        throw "缺少目录 $Path"
    }
}

function Invoke-NativeExe {
    <#
      安全执行外部命令并捕获输出。
      作用：$ErrorActionPreference='Stop' 时，native 程序写入 stderr（如 mysql 的密码告警）
            会被 PowerShell 包成 NativeCommandError 抛出；本函数内临时降级为 Continue。
      返回：@{ Code = 退出码; Output = 输出行数组 }
    #>
    param(
        [string]$FilePath,
        [string[]]$Arguments = @()
    )
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & $FilePath @Arguments 2>&1
        return @{ Code = $LASTEXITCODE; Output = @($out) }
    } catch {
        return @{ Code = -1; Output = @($_.Exception.Message) }
    } finally {
        $ErrorActionPreference = $saved
    }
}

function Show-ExeFirstLine {
    <# 通过 cmd 合并 stderr，稳定拿到某个命令的首行版本信息 #>
    param([string]$FileName, [string]$Arguments = '')
    $cmd = Get-Command $FileName -ErrorAction SilentlyContinue
    if (-not $cmd) { return $null }
    $result = Invoke-NativeExe -FilePath 'cmd.exe' -Arguments @('/c', "$FileName $Arguments 2>&1")
    $line = $result.Output | Where-Object { $_ -and $_.ToString().Trim() -ne '' } | Select-Object -First 1
    if (-not $line) { return '(无输出)' }
    return $line.ToString().Trim()
}
