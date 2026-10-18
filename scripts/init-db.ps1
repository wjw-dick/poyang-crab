# 数据库初始化（幂等）：poyang_crab 建库 + 建表 + 初始化数据
#
# 用法：
#   scripts\init-db.bat
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\init-db.ps1 -Force
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\init-db.ps1 -Force -WithDemo
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\init-db.ps1 -RootUser root -RootPassword 你的root密码
#
# 说明：
#   * 库/账号已存在且已有表时默认跳过；加 -Force 重新执行
#     （SQL 脚本本身无 DROP / TRUNCATE，仅 IF NOT EXISTS / ON DUPLICATE KEY 级幂等操作）
#   * 库或账号尚未创建时，需 root 权限执行 00_create_database.sql，可通过 -RootPassword 传入
#   * -WithDemo 额外写入 98_demo_data.sql 演示数据（商品/会员/订单/渠道/文章等），
#     仅用于本地与演示环境，生产环境不要加此参数
[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$WithDemo,
    [string]$RootUser = 'root',
    [string]$RootPassword = ''
)

. "$PSScriptRoot\_common.ps1"

Write-Title '数据库初始化（poyang_crab）'

$mysqlExe = Resolve-MysqlExe
if (-not $mysqlExe) {
    Write-Err '未找到 mysql.exe，请将其所在目录加入 PATH 或安装 MySQL 客户端'
    exit 1
}
Write-Ok "mysql 客户端：$mysqlExe"

# ---------------- 工具函数 ----------------
function Invoke-Mysql {
    param([string]$User, [string]$Password, [string]$Database, [string]$Command)
    $env:MYSQL_PWD = $Password
    $argv = @('--default-character-set=utf8mb4', '-h', $DbHost, '-P', "$DbPort", '-u', $User)
    if ($Database) { $argv += @('-D', $Database) }
    $argv += @('-e', $Command)
    return Invoke-NativeExe -FilePath $mysqlExe -Arguments $argv
}

function Test-DbConn {
    param([string]$User, [string]$Password)
    $r = Invoke-Mysql -User $User -Password $Password -Database '' -Command 'SELECT 1'
    return ($r.Code -eq 0)
}

function Get-TableCount {
    $sql = "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DbName'"
    $env:MYSQL_PWD = $DbPassword
    $argv = @('--default-character-set=utf8mb4', '-N', '-B', '-h', $DbHost, '-P', "$DbPort", '-u', $DbUser,
              '-e', $sql)
    $r = Invoke-NativeExe -FilePath $mysqlExe -Arguments $argv
    if ($r.Code -ne 0) { return -1 }
    $line = $r.Output | Where-Object { $_ -match '^\s*\d+\s*$' } | Select-Object -Last 1
    if (-not $line) { return -1 }
    return [int]($line.ToString().Trim())
}

function Invoke-SqlFile {
    param([string]$File, [string]$User, [string]$Password, [string]$Database)
    $name = Split-Path -Leaf $File
    $path = ($File -replace '\\', '/')
    $env:MYSQL_PWD = $Password
    $argv = @('--default-character-set=utf8mb4', '-h', $DbHost, '-P', "$DbPort", '-u', $User)
    if ($Database) { $argv += @('-D', $Database) }
    $argv += @('-e', "source $path")
    $r = Invoke-NativeExe -FilePath $mysqlExe -Arguments $argv
    if ($r.Code -eq 0) {
        Write-Ok "$name 执行成功"
    } else {
        Write-Err "$name 执行失败（exit=$($r.Code)）"
        $r.Output | Select-Object -First 5 | ForEach-Object { Write-Host "        $_" -ForegroundColor DarkRed }
    }
    return $r.Code
}

# ---------------- 1. 连通性 ----------------
Write-Title '1. 连接检查'
$bizOk = Test-DbConn -User $DbUser -Password $DbPassword
if ($bizOk) {
    Write-Ok "业务账号可用：$DbUser@$($DbHost):$DbPort"
} else {
    Write-Warn "业务账号 $DbUser 无法连接（库或账号可能尚未创建）"
    if ([string]::IsNullOrEmpty($RootPassword)) {
        Write-Err '请先用 root 执行一次建库脚本，例如：'
        Write-Host "        mysql -u root -p < `"$SqlDir\00_create_database.sql`"" -ForegroundColor DarkGray
        Write-Host '      或带参数重跑本脚本：-RootUser root -RootPassword <你的root密码>' -ForegroundColor DarkGray
        exit 1
    }
    Write-Step '使用 root 账号创建库与业务账号 ...'
    $code = Invoke-SqlFile -File (Join-Path $SqlDir '00_create_database.sql') -User $RootUser -Password $RootPassword -Database ''
    if ($code -ne 0) {
        Write-Err '00_create_database.sql 执行失败，请检查 root 账号与密码'
        exit 1
    }
    if (-not (Test-DbConn -User $DbUser -Password $DbPassword)) {
        Write-Err '建库后业务账号仍无法连接，请检查账号权限'
        exit 1
    }
    Write-Ok "业务账号已可用：$DbUser"
}

# ---------------- 2. 是否已初始化 ----------------
Write-Title '2. 现状检查'
$tableCount = Get-TableCount
Write-Step "当前表数量：$tableCount"
if ($tableCount -gt 0 -and -not $Force) {
    Write-Ok '数据库已初始化，跳过建表（如需强制重跑请加 -Force）'
    Write-Title '完成'
    exit 0
}

# ---------------- 3. 执行建表与初始化数据 ----------------
Write-Title '3. 执行 SQL 脚本'
$ordered = @(
    '01_system.sql',
    '02_member_product.sql',
    '03_order.sql',
    '04_channel.sql',
    '05_cms.sql',
    '99_init_data.sql'
)
foreach ($f in $ordered) {
    $file = Join-Path $SqlDir $f
    if (-not (Test-Path $file)) {
        Write-Err "缺少 SQL 文件：$file"
        exit 1
    }
    $code = Invoke-SqlFile -File $file -User $DbUser -Password $DbPassword -Database $DbName
    if ($code -ne 0) {
        Write-Err "初始化中断于 $f"
        exit 1
    }
}

# ---------------- 3.5 可选演示数据 ----------------
if ($WithDemo) {
    $demoFile = Join-Path $SqlDir '98_demo_data.sql'
    if (-not (Test-Path $demoFile)) {
        Write-Err "缺少演示数据脚本：$demoFile"
        exit 1
    }
    Write-Step '写入演示数据（-WithDemo）...'
    $code = Invoke-SqlFile -File $demoFile -User $DbUser -Password $DbPassword -Database $DbName
    if ($code -ne 0) {
        Write-Err '演示数据写入失败（不影响基础初始化）'
    }
} else {
    Write-Step '未启用演示数据（如需灌入请加 -WithDemo）'
}

# ---------------- 4. 结果 ----------------
Write-Title '4. 结果'
Write-Ok "表数量：$(Get-TableCount)"
$r = Invoke-Mysql -User $DbUser -Password $DbPassword -Database $DbName -Command 'SELECT username, real_name, status FROM sys_user LIMIT 5'
if ($r.Code -eq 0) {
    $r.Output | ForEach-Object { Write-Host "        $_" -ForegroundColor DarkGray }
}

Write-Title '完成'
Write-Host '  初始账号：admin / Admin@123456（上线前必须修改）' -ForegroundColor Yellow
exit 0
