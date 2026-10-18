# 原生启动脚本（Windows / 非 Docker）

面向**本机已安装** MySQL 8 / Redis / RabbitMQ 的开发模式，一键拉起「后端 + 后台 + H5」。

## 快速开始

```bat
:: 1) 首次：环境自检（看运行时 / 中间件 / 目录是否齐备）
scripts\check-env.bat

:: 2) 首次：初始化数据库（建库建表 + 初始数据，幂等）
scripts\init-db.bat
::    若库/账号尚未创建，用 root 建：
::    powershell -File scripts\init-db.ps1 -RootUser root -RootPassword <你的root密码>
::    想要演示数据（商品/会员/订单/渠道/文章…列表页都有数据，便于验收）：
::    powershell -NoProfile -ExecutionPolicy Bypass -File scripts\init-db.ps1 -Force -WithDemo

:: 3) 一键启动（后端 :8080 / 后台 :8848 / H5 :8849）
scripts\start-all.bat

:: 4) 停止
scripts\stop-all.bat
```

启动完成后：

| 服务 | 地址 | 账号 |
| --- | --- | --- |
| 后端 API | http://localhost:8080/api | — |
| 健康检查 | http://localhost:8080/api/actuator/health | — |
| 后台管理 | http://localhost:8848/ | `admin` / `Admin@123456` |
| H5 / PC 官网 | http://localhost:8849/ | — |

## 脚本清单

| 文件 | 作用 |
| --- | --- |
| `_common.ps1` | 公共库：路径/端口/中间件配置、端口探测、进程启停、输出样式（被其余脚本 dot-source） |
| `check-env.ps1` | 环境自检：Java/Maven/Node/npm、中间件端口、mysql/redis 客户端、工程目录、SQL 脚本、应用端口占用 |
| `init-db.ps1` | 数据库初始化（幂等；已有表默认跳过，`-Force` 强制重跑） |
| `start-backend.ps1` | 启动后端（`mvn spring-boot:run`，新窗口，等待健康检查通过） |
| `start-admin.ps1` | 启动后台前端（Vite `:8848`，缺 `node_modules` 时自动 `npm install`） |
| `start-h5.ps1` | 启动 H5 / PC 官网（Vite `:8849`） |
| `start-all.ps1` | 一键编排：依赖检查 → 数据库 → 后端 → 对象存储 → 后台 → H5 |
| `stop-all.ps1` | 停止全部服务（先按启动记录的窗口 PID，再按端口兜底） |

每个脚本都有同名 `.bat` 包装器，**可直接双击运行**。

## 常用参数

```powershell
# 首次一键启动（含建库建表）
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\start-all.ps1 -InitDb

# 只启动后端（调试接口用）
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\start-all.ps1 -OnlyBackend

# 跳过中间件端口检查（中间件装在别的机器时）
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\start-all.ps1 -SkipDeps

# 强制重建所有表（脚本内无 DROP/TRUNCATE，仅重放幂等 SQL）
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\init-db.ps1 -Force
```

## 配置覆盖

默认值可通过**环境变量**覆盖（无需改脚本）：

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `CRAB_DB_HOST` / `CRAB_DB_PORT` | `127.0.0.1` / `3306` | MySQL 地址 |
| `CRAB_DB_NAME` | `poyang_crab` | 库名 |
| `CRAB_DB_USER` / `CRAB_DB_PASSWORD` | `poyang_crab` / `BZcEXmWxiDcmx5bw` | 业务账号 |
| `CRAB_REDIS_HOST` / `CRAB_REDIS_PORT` | `127.0.0.1` / `6379` | Redis 地址 |
| `CRAB_RABBIT_HOST` / `CRAB_RABBIT_PORT` | `127.0.0.1` / `5672` | RabbitMQ 地址 |

例如：

```powershell
$env:CRAB_DB_PASSWORD = 'your-strong-password'
scripts\start-all.bat
```

## 行为说明

- **服务各自独立窗口**：每个服务在单独的 PowerShell 窗口中运行，关掉窗口即停止该服务，窗口内可直接看到实时日志。
- **后端日志**：同时写入 `poyang-crab-backend/logs/poyang-crab-backend.log`。
- **对象存储兜底**：若本机 `:9000`（MinIO）未监听，脚本会通过后端接口把驱动自动切到 `LOCAL`（本地磁盘 `poyang-crab-backend/data/upload`），并同步数据库与 Redis。
- **未部署 MinIO 也能跑通上传**，无需额外配置。
- **进程记录**：启动时的窗口 PID 记录在 `.run/*.pid`，供 `stop-all.ps1` 精确回收。

## 常见问题

| 现象 | 处理 |
| --- | --- |
| `mysql.exe` / `redis-cli.exe` 未找到 | 把对应 `bin` 目录加入 PATH，或安装到脚本内置的候选路径（宝塔 `D:\BtSoft\...`、`C:\Program Files\...`） |
| 后端窗口报 `Unsupported character encoding 'utf8mb4'` | JDBC URL 的 `characterEncoding` 必须写 `UTF-8`（勿写成 `utf8mb4`） |
| 后台/H5 窗口报依赖缺失 | 脚本会自动 `npm install`；Windows 下务必使用 `npm.cmd`（`npm.ps1` 可能被执行策略拦截） |
| 端口 8080/8848/8849 被占用 | 先执行 `scripts\stop-all.bat`，或手动结束占用进程 |
| PowerShell 提示无法加载脚本（执行策略） | 用 `.bat` 包装器运行（已内置 `-ExecutionPolicy Bypass`），或执行 `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |

> 脚本文件统一保存为 **UTF-8 with BOM**，以保证 Windows PowerShell 5.1 下中文正常显示。
