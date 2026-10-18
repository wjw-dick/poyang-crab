# 环境自检：运行时 / 中间件端口 / 工程目录 / SQL 脚本
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-env.ps1
. "$PSScriptRoot\_common.ps1"

Write-Title '螃蟹小公主 · 鄱阳湖湖蟹 —— 环境自检（原生 / 非 Docker）'

# ---------------- 1. 运行时 ----------------
Write-Title '1. 运行时'
function Show-Tool {
    param([string]$Name, [string]$Command, [string]$ArgLine)
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        Write-Err ("{0,-6}: 未找到（{1}），请先安装并加入 PATH" -f $Name, $Command)
        return
    }
    $line = Show-ExeFirstLine -FileName $Command -Arguments $ArgLine
    Write-Ok ("{0,-6}: {1}" -f $Name, $line)
}
Show-Tool 'Java'  'java'    '-version'
Show-Tool 'Maven' 'mvn'     '-v'
Show-Tool 'Node'  'node'    '-v'
Show-Tool 'npm'   'npm.cmd' '-v'

# ---------------- 2. 中间件端口 ----------------
Write-Title '2. 中间件（必须已在本机运行）'
$deps = @(
    @{ Name = 'MySQL 8';  Host = $DbHost;     Port = $DbPort;     Required = $true  },
    @{ Name = 'Redis';    Host = $RedisHost;  Port = $RedisPort;  Required = $true  },
    @{ Name = 'RabbitMQ'; Host = $RabbitHost; Port = $RabbitPort; Required = $true  },
    @{ Name = 'MinIO';    Host = '127.0.0.1'; Port = $MinioPort;  Required = $false }
)
foreach ($d in $deps) {
    $up = Test-TcpPort -ComputerName $d.Host -Port $d.Port
    if ($up) {
        Write-Ok ("{0,-9}: {1}:{2} 可连接" -f $d.Name, $d.Host, $d.Port)
    } elseif ($d.Required) {
        Write-Err ("{0,-9}: {1}:{2} 未监听 —— 请先启动该组件" -f $d.Name, $d.Host, $d.Port)
    } else {
        Write-Warn ("{0,-9}: {1}:{2} 未监听（可选）—— 对象存储将使用 LOCAL 本地磁盘" -f $d.Name, $d.Host, $d.Port)
    }
}

# ---------------- 3. 客户端工具 ----------------
Write-Title '3. 数据库 / Redis 客户端'
$mysqlExe = Resolve-MysqlExe
if ($mysqlExe) { Write-Ok "mysql.exe    : $mysqlExe" } else { Write-Warn 'mysql.exe    : 未找到（init-db 脚本将无法自动初始化数据库）' }
$redisCli = Resolve-RedisCliExe
if ($redisCli) { Write-Ok "redis-cli.exe: $redisCli" } else { Write-Warn 'redis-cli.exe: 未找到（不影响启动，仅无法用脚本切换存储驱动）' }

# ---------------- 4. 工程目录 ----------------
Write-Title '4. 工程目录'
$dirs = @(
    @{ Name = '后端';        Path = $BackendDir },
    @{ Name = '后台';        Path = $AdminDir   },
    @{ Name = 'H5/官网';     Path = $H5Dir      },
    @{ Name = '小程序(C端)'; Path = $MiniDir    },
    @{ Name = '小程序(渠道)'; Path = $ChannelDir }
)
foreach ($d in $dirs) {
    if (Test-Path $d.Path) { Write-Ok ("{0,-13}: {1}" -f $d.Name, $d.Path) }
    else { Write-Err ("{0,-13}: 缺失 {1}" -f $d.Name, $d.Path) }
}
foreach ($n in @('poyang-crab-backend\pom.xml', 'poyang-crab-admin\package.json', 'poyang-crab-h5\package.json')) {
    $p = Join-Path $CrabRoot $n
    if (Test-Path $p) { Write-Ok ("清单 {0}" -f $n) } else { Write-Err ("清单缺失 {0}" -f $n) }
}

# ---------------- 5. SQL 脚本 ----------------
Write-Title '5. 数据库脚本'
$sqlFiles = @('00_create_database.sql', '01_system.sql', '02_member_product.sql', '03_order.sql', '04_channel.sql', '05_cms.sql', '99_init_data.sql')
foreach ($f in $sqlFiles) {
    $p = Join-Path $SqlDir $f
    if (Test-Path $p) { Write-Ok $f } else { Write-Err "缺失 $f" }
}

# ---------------- 6. 应用端口占用 ----------------
Write-Title '6. 应用端口'
foreach ($app in @(
    @{ Name = '后端 API'; Port = $BackendPort },
    @{ Name = '后台';     Port = $AdminPort   },
    @{ Name = 'H5/官网';  Port = $H5Port      }
)) {
    $ownerPid = Get-ListenPid $app.Port
    if ($ownerPid -gt 0) { Write-Warn ("{0,-9}: {1} 已被占用（PID {2}）" -f $app.Name, $app.Port, $ownerPid) }
    else { Write-Ok ("{0,-9}: {1} 空闲" -f $app.Name, $app.Port) }
}

Write-Title '自检完成'
Write-Host '  [OK] 全部就绪   [X] 阻塞项需先修复   [!] 提醒项不影响启动但建议关注' -ForegroundColor DarkGray
